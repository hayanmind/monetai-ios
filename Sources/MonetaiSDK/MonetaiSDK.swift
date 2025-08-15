import Foundation
import Combine
import UIKit

/// Struct representing event logging options
@objc public class LogEventOptions: NSObject {
    @objc public let eventName: String
    @objc public let params: [String: Any]?
    @objc public let createdAt: Date
    
    @objc public init(eventName: String, params: [String: Any]? = nil, createdAt: Date = Date()) {
        self.eventName = eventName
        self.params = params
        self.createdAt = createdAt
        super.init()
    }
}

/// Event logging convenience initializer methods
public extension LogEventOptions {
    /// Basic event (without parameters)
    @objc static func event(_ eventName: String) -> LogEventOptions {
        return LogEventOptions(eventName: eventName)
    }
    
    /// Event with parameters
    @objc static func event(_ eventName: String, params: [String: Any]) -> LogEventOptions {
        return LogEventOptions(eventName: eventName, params: params)
    }
}

/// MonetaiSDK main class
@objc public class MonetaiSDK: NSObject, ObservableObject {
    
    // MARK: - Singleton
    @objc public static let shared = MonetaiSDK()
    
    // MARK: - Properties
    @Published public private(set) var isInitialized: Bool = false
    @Published public private(set) var exposureTimeSec: Int?
    @Published public private(set) var currentDiscount: AppUserDiscount?
    
    private var sdkKey: String?
    private var userId: String?
    private var campaign: Campaign?
    private var pendingEvents: [LogEventOptions] = []
    
    // MARK: - Internal Properties for StoreKit
    internal var currentSDKKey: String? { return sdkKey }
    internal var currentUserId: String? { return userId }
    
    // MARK: - Event Publisher
    public let discountInfoLoaded = PassthroughSubject<Void, Never>()
    
    // MARK: - Discount Info Callback (Swift only)
    public var onDiscountInfoChange: ((AppUserDiscount?) -> Void)?
    
    // MARK: - Objective-C Compatible Callback
    @objc public var onDiscountInfoChangeCallback: ((Any?) -> Void)?
    
    // MARK: - Paywall Management
    public let paywallManager = MonetaiPaywallManager()
    public let bannerManager = MonetaiBannerManager()
    
    // MARK: - Paywall Configuration
    private var paywallConfig: PaywallConfig?

    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Initialize MonetaiSDK
    /// - Parameters:
    ///   - sdkKey: SDK key (required)
    ///   - userId: User unique ID (required)
    ///   - useStoreKit2: Whether to use StoreKit2 (default: false)
    /// - Returns: Initialization result
    @MainActor
    public func initialize(
        sdkKey: String,
        userId: String,
        useStoreKit2: Bool = false
    ) async throws -> InitializeResult {
        
        // Validation
        guard !sdkKey.isEmpty else {
            throw MonetaiError.invalidSDKKey
        }
        
        guard !userId.isEmpty else {
            throw MonetaiError.invalidUserId
        }
        
        // If already initialized
        if isInitialized {
            return InitializeResult(
                organizationId: 0, // In practice, use stored value
                platform: "ios",
                version: SDKVersion.getVersion(),
                userId: userId,
                group: nil // In practice, use stored value
            )
        }
        
        // Store SDK key and user ID
        self.sdkKey = sdkKey
        self.userId = userId
        
        // Start StoreKit observation
        StoreKitManager.shared.startObserving(useStoreKit2: useStoreKit2)
        
        // Send receipt (in background)
        Task {
            await StoreKitManager.shared.sendReceipt()
        }
        
        // API initialization
        let (initResponse, abTestResponse) = try await APIRequests.initialize(sdkKey: sdkKey, userId: userId)
        
        // Store campaign information
        self.campaign = abTestResponse.campaign
        self.exposureTimeSec = abTestResponse.campaign?.exposureTimeSec
        
        // Initialization complete
        isInitialized = true
        
        // Process pending events
        print("[MonetaiSDK] 📋 SDK initialization complete - Starting to process pending events...")
        await processPendingEvents()
        print("[MonetaiSDK] ✅ Pending events processing complete")
        
        // Trigger discount info loaded event
        discountInfoLoaded.send()
        
        // Automatically check discount information after initialization
        await loadDiscountInfoAutomatically()
        
        return InitializeResult(
            organizationId: initResponse.organizationId,
            platform: initResponse.platform,
            version: initResponse.version,
            userId: userId,
            group: abTestResponse.group
        )
    }
    
    /// Automatically load discount information and update state
    @MainActor
    private func loadDiscountInfoAutomatically() async {
        guard let sdkKey = sdkKey, let userId = userId else {
            return
        }
        
        do {
            let discount = try await APIRequests.getAppUserDiscount(sdkKey: sdkKey, userId: userId)
            
            // Check if discount information belongs to current user
            if let discount = discount, discount.appUserId != userId {
                return
            }
            
            // Update state
            currentDiscount = discount
            
            // Call callback
            onDiscountInfoChange?(discount)
            onDiscountInfoChangeCallback?(discount as Any?)
            
            // Update paywall managers if config exists
            if paywallConfig != nil {
                configureManagersAndUpdateBanner()
            }
            
            print("[MonetaiSDK] Discount information auto-load complete: \(discount != nil ? "Discount available" : "No discount")")
            
        } catch {
            print("[MonetaiSDK] Discount information auto-load failed: \(error)")
            currentDiscount = nil
            onDiscountInfoChange?(nil)
            onDiscountInfoChangeCallback?(nil as Any?)
        }
    }
    
    /// Log event (using LogEventOptions)
    /// - Parameter options: Event options to log
    @MainActor
    public func logEvent(_ options: LogEventOptions) async {
        print("[MonetaiSDK] Event logging request: \(options.eventName)")
        print("[MonetaiSDK] Event parameters: \(options.params ?? [:])")
        
        guard let sdkKey = sdkKey, let userId = userId else {
            // Add to queue if SDK is not initialized
            pendingEvents.append(options)
            print("[MonetaiSDK] ⏳ Before SDK initialization - Added to queue: \(options.eventName)")
            print("[MonetaiSDK] 📦 Current number of pending events: \(pendingEvents.count)")
            print("[MonetaiSDK] 📋 Pending events list: \(pendingEvents.map { $0.eventName })")
            return
        }
        
        print("[MonetaiSDK] ✅ SDK initialized - Sending immediately: \(options.eventName)")
        
        do {
            try await APIRequests.createEvent(
                sdkKey: sdkKey,
                userId: userId,
                eventName: options.eventName,
                params: options.params,
                createdAt: options.createdAt
            )
            print("[MonetaiSDK] 🎉 Event logging success: \(options.eventName)")
        } catch {
            print("[MonetaiSDK] ❌ Event logging failed: \(options.eventName)")
            print("[MonetaiSDK] Error details: \(error)")
        }
    }
    
    /// Log event (basic method)
    /// - Parameters:
    ///   - eventName: Event name
    ///   - params: Event parameters (optional)
    @MainActor
    public func logEvent(eventName: String, params: [String: Any]? = nil) async {
        let options = LogEventOptions(eventName: eventName, params: params)
        await logEvent(options)
    }
    
    /// Perform user prediction
    /// - Returns: Prediction result
    @MainActor
    public func predict() async throws -> PredictResponse {
        guard let sdkKey = sdkKey, let userId = userId else {
            throw MonetaiError.notInitialized
        }
        
        guard let exposureTimeSec = exposureTimeSec else {
            throw MonetaiError.notInitialized
        }
        
        let result = try await APIRequests.predict(sdkKey: sdkKey, userId: userId)
        
        // Create discount for non-purchaser prediction
        if result.prediction == .nonPurchaser {
            await handleNonPurchaserPrediction(sdkKey: sdkKey, userId: userId, exposureTimeSec: exposureTimeSec)
        }
        
        return PredictResponse(
            prediction: result.prediction,
            testGroup: result.testGroup
        )
    }
    
    /// Get current user's discount information
    /// - Returns: Discount information (nil if none)
    @MainActor
    public func getCurrentDiscount() async throws -> AppUserDiscount? {
        guard let sdkKey = sdkKey, let userId = userId else {
            throw MonetaiError.notInitialized
        }
        
        return try await APIRequests.getAppUserDiscount(sdkKey: sdkKey, userId: userId)
    }
    
    /// Check if active discount exists
    /// - Returns: Whether active discount exists
    @MainActor
    public func hasActiveDiscount() async throws -> Bool {
        guard let discount = try await getCurrentDiscount() else {
            return false
        }
        
        return discount.endedAt > Date()
    }
    
    /// Reset SDK
    @MainActor
    @objc public func reset() {
        sdkKey = nil
        userId = nil
        campaign = nil
        exposureTimeSec = nil
        isInitialized = false
        pendingEvents.removeAll()
        
        // Stop StoreKit observation
        StoreKitManager.shared.stopObserving()
    }
    
    /// Return current user ID
    @objc public func getUserId() -> String? {
        return userId
    }
    
    /// Return current SDK key
    @objc public func getSdkKey() -> String? {
        return sdkKey
    }
    
    /// Return SDK initialization status
    @objc public func getInitialized() -> Bool {
        return isInitialized
    }
    
    /// Return current exposure time (seconds)
    
    // MARK: - Paywall Methods
    
    /// Configure paywall with the specified configuration
    /// - Parameter config: Paywall configuration
    @objc public func configurePaywall(_ config: PaywallConfig) {
        self.paywallConfig = config
        
        // Configure managers and update banner
        configureManagersAndUpdateBanner()
    }
    

    

    



    

    
    // MARK: - Private Helper Methods
    
    /// Configure paywall and banner managers, then update banner visibility
    private func configureManagersAndUpdateBanner() {
        guard let paywallConfig = paywallConfig,
              let discountInfo = convertToDiscountInfo() else { return }
        
        // Configure managers
        paywallManager.configure(paywallConfig: paywallConfig, discountInfo: discountInfo)
        bannerManager.configure(paywallConfig: paywallConfig, discountInfo: discountInfo, paywallManager: paywallManager)
        
        // Auto control banner visibility based on current discount state and paywall config
        guard let discount = currentDiscount,
              discount.endedAt > Date(),
              paywallConfig.enabled else {
            // Hide banner if no discount, expired, or paywall disabled
            if bannerManager.bannerVisible {
                bannerManager.hideBanner()
            }
            return
        }
        
        // Show banner if discount is active and paywall is enabled
        if !bannerManager.bannerVisible {
            bannerManager.showBanner()
        }
    }
    
    private func convertToDiscountInfo() -> DiscountInfo? {
        guard let currentDiscount = currentDiscount else { return nil }
        
        return DiscountInfo(
            startedAt: currentDiscount.startedAt,
            endedAt: currentDiscount.endedAt,
            userId: currentDiscount.appUserId,
            sdkKey: currentDiscount.sdkKey
        )
    }
    public func getExposureTimeSec() -> Int? {
        return exposureTimeSec
    }
    
    // MARK: - Objective-C Compatible Methods
    
    /// Initialize MonetaiSDK (Objective-C compatible)
    /// - Parameters:
    ///   - sdkKey: SDK key (required)
    ///   - userId: User unique ID (required)
    ///   - useStoreKit2: Whether to use StoreKit2 (default: false)
    ///   - completion: Completion handler with result
    @objc public func initializeWithSdkKey(_ sdkKey: String, 
                                          userId: String, 
                                          useStoreKit2: Bool, 
                                          completion: @escaping (InitializeResult?, Error?) -> Void) {
        Task {
            do {
                let result = try await initialize(sdkKey: sdkKey, userId: userId, useStoreKit2: useStoreKit2)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    /// Perform user prediction (Objective-C compatible)
    /// - Parameter completion: Completion handler with result
    @objc public func predictWithCompletion(_ completion: @escaping (PredictResponse?, Error?) -> Void) {
        Task {
            do {
                let result = try await predict()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    /// Log event (Objective-C compatible)
    /// - Parameters:
    ///   - eventName: Event name
    ///   - params: Event parameters (optional)
    @objc public func logEventWithEventName(_ eventName: String, params: [String: Any]? = nil) {
        Task {
            await logEvent(eventName: eventName, params: params)
        }
    }
    
    /// Get current user's discount information (Objective-C compatible)
    /// - Parameter completion: Completion handler with result
    @objc public func getCurrentDiscountWithCompletion(_ completion: @escaping (AppUserDiscount?, Error?) -> Void) {
        Task {
            do {
                let discount = try await getCurrentDiscount()
                completion(discount, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    /// Check if active discount exists (Objective-C compatible)
    /// - Parameter completion: Completion handler with result
    @objc public func hasActiveDiscountWithCompletion(_ completion: @escaping (Bool, Error?) -> Void) {
        Task {
            do {
                let hasDiscount = try await hasActiveDiscount()
                completion(hasDiscount, nil)
            } catch {
                completion(false, error)
            }
        }
    }
    
    // MARK: - Paywall Methods (Objective-C Compatible)
    
    /// Configure paywall (Objective-C compatible)
    /// - Parameter config: Paywall configuration
    @objc public func configurePaywallWithConfig(_ config: PaywallConfig) {
        configurePaywall(config)
    }
    

    

    

    

    
    // MARK: - Private Methods
    
    private func processPendingEvents() async {
        guard let sdkKey = sdkKey, let userId = userId else { return }
        
        let events = pendingEvents
        pendingEvents.removeAll()
        
        print("[MonetaiSDK] 🚀 Starting to process pending events")
        print("[MonetaiSDK] 📊 Number of events to process: \(events.count)")
        
        if events.isEmpty {
            print("[MonetaiSDK] ℹ️ No pending events to process")
            return
        }
        
        print("[MonetaiSDK] 📋 List of events to process: \(events.map { $0.eventName })")
        
        for (index, event) in events.enumerated() {
            print("[MonetaiSDK] 📤 Processing \(index + 1)/\(events.count): \(event.eventName)")
            
            do {
                try await APIRequests.createEvent(
                    sdkKey: sdkKey,
                    userId: userId,
                    eventName: event.eventName,
                    params: event.params,
                    createdAt: event.createdAt
                )
                print("[MonetaiSDK] ✅ \(index + 1)/\(events.count) Success: \(event.eventName)")
            } catch {
                print("[MonetaiSDK] ❌ \(index + 1)/\(events.count) Failed: \(event.eventName)")
                print("[MonetaiSDK] Error details: \(error)")
            }
        }
        
        print("[MonetaiSDK] 🎉 Pending events processing complete")
    }
    
    private func handleNonPurchaserPrediction(sdkKey: String, userId: String, exposureTimeSec: Int) async {
        do {
            // Check existing discount information
            let existingDiscount = try await APIRequests.getAppUserDiscount(sdkKey: sdkKey, userId: userId)
            
            let now = Date()
            let hasActiveDiscount = existingDiscount != nil && existingDiscount!.endedAt > now
            
            if !hasActiveDiscount {
                // Create new discount
                let startedAt = now
                let endedAt = Calendar.current.date(byAdding: .second, value: exposureTimeSec, to: startedAt) ?? startedAt
                
                _ = try await APIRequests.createAppUserDiscount(
                    sdkKey: sdkKey,
                    userId: userId,
                    startedAt: startedAt,
                    endedAt: endedAt
                )
                
                // Trigger discount info loaded event
                discountInfoLoaded.send()
                
                // Automatically load discount information
                await loadDiscountInfoAutomatically()
            }
        } catch {
            print("[MonetaiSDK] Discount creation failed: \(error)")
        }
    }
}

// MARK: - Result Types

/// Initialization result
@objc public class InitializeResult: NSObject {
    @objc public let organizationId: Int
    @objc public let platform: String
    @objc public let version: String
    @objc public let userId: String
    public let group: ABTestGroup?
    
    public init(organizationId: Int, platform: String, version: String, userId: String, group: ABTestGroup?) {
        self.organizationId = organizationId
        self.platform = platform
        self.version = version
        self.userId = userId
        self.group = group
        super.init()
    }
    
    // Objective-C compatible getters
    @objc public var groupString: String? {
        return group?.stringValue
    }
    
    // Custom description for better logging
    public override var description: String {
        return "InitializeResult(organizationId: \(organizationId), platform: \"\(platform)\", version: \"\(version)\", userId: \"\(userId)\", group: \(group?.stringValue ?? "nil"))"
    }
}

/// Prediction response result
@objc public class PredictResponse: NSObject {
    public let prediction: PredictResult?
    public let testGroup: ABTestGroup?
    
    public init(prediction: PredictResult?, testGroup: ABTestGroup?) {
        self.prediction = prediction
        self.testGroup = testGroup
        super.init()
    }
    
    // Objective-C compatible getters
    @objc public var predictionString: String? {
        return prediction?.stringValue
    }
    
    @objc public var testGroupString: String? {
        return testGroup?.stringValue
    }
    
    // Custom description for better logging
    public override var description: String {
        return "PredictResponse(prediction: \(prediction?.stringValue ?? "nil"), testGroup: \(testGroup?.stringValue ?? "nil"))"
    }
} 
