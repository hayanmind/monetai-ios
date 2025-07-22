import Foundation
import Combine

/// Struct representing event logging options
public struct LogEventOptions {
    public let eventName: String
    public let params: [String: Any]?
    public let createdAt: Date
    
    public init(eventName: String, params: [String: Any]? = nil, createdAt: Date = Date()) {
        self.eventName = eventName
        self.params = params
        self.createdAt = createdAt
    }
}

/// Event logging convenience initializer methods
public extension LogEventOptions {
    /// Basic event (without parameters)
    static func event(_ eventName: String) -> LogEventOptions {
        return LogEventOptions(eventName: eventName)
    }
    
    /// Event with parameters
    static func event(_ eventName: String, params: [String: Any]) -> LogEventOptions {
        return LogEventOptions(eventName: eventName, params: params)
    }
}

/// MonetaiSDK main class
public class MonetaiSDK: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = MonetaiSDK()
    
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
    
    // MARK: - Discount Info Callback
    public var onDiscountInfoChange: ((AppUserDiscount?) -> Void)?
    
    private init() {}
    
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
            
            print("[MonetaiSDK] Discount information auto-load complete: \(discount != nil ? "Discount available" : "No discount")")
            
        } catch {
            print("[MonetaiSDK] Discount information auto-load failed: \(error)")
            currentDiscount = nil
            onDiscountInfoChange?(nil)
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
    public func reset() {
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
    public func getUserId() -> String? {
        return userId
    }
    
    /// Return current SDK key
    public func getSdkKey() -> String? {
        return sdkKey
    }
    
    /// Return SDK initialization status
    public func getInitialized() -> Bool {
        return isInitialized
    }
    
    /// Return current exposure time (seconds)
    public func getExposureTimeSec() -> Int? {
        return exposureTimeSec
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
public struct InitializeResult {
    public let organizationId: Int
    public let platform: String
    public let version: String
    public let userId: String
    public let group: ABTestGroup?
}

/// Prediction response result
public struct PredictResponse {
    public let prediction: PredictResult?
    public let testGroup: ABTestGroup?
} 