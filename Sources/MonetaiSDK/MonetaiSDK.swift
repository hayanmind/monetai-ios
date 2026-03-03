import Foundation
import Combine

/// Struct representing event logging options
@objc public class LogEventOptions: NSObject {
    @objc public let eventName: String
    @objc public let params: [String: Any]?

    @objc public init(eventName: String, params: [String: Any]? = nil) {
        self.eventName = eventName
        self.params = params
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

// MARK: - Pending Event Types

/// Pending custom event (logged before SDK initialization)
private struct PendingCustomEvent {
    let eventName: String
    let params: [String: Any]?
    let clientTimestamp: TimeInterval // Date().timeIntervalSince1970 * 1000
}

/// Pending view product item event (logged before SDK initialization)
private struct PendingViewProductItemEvent {
    let params: ViewProductItemParams
    let clientTimestamp: TimeInterval
}

/// Discriminated union for pending events
private enum PendingEvent {
    case logEvent(PendingCustomEvent)
    case viewProductItem(PendingViewProductItemEvent)
}

/// MonetaiSDK main class
@objc public class MonetaiSDK: NSObject, ObservableObject {

    // MARK: - Singleton
    @objc public static let shared = MonetaiSDK()

    // MARK: - Properties
    @Published public private(set) var isInitialized: Bool = false

    private var sdkKey: String?
    private var userId: String?
    private var organizationId: Int = 0
    private var pendingEvents: [PendingEvent] = []

    /// Server-client time offset in milliseconds (serverTimestamp - clientTimestamp)
    private var serverTimeOffset: Int64 = 0

    // MARK: - Internal Properties for StoreKit
    internal var currentSDKKey: String? { return sdkKey }
    internal var currentUserId: String? { return userId }

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
                organizationId: organizationId,
                platform: "ios",
                version: SDKVersion.getVersion(),
                userId: userId
            )
        }

        // Store SDK key and user ID
        self.sdkKey = sdkKey
        self.userId = userId

        // Set API headers
        APIClient.shared.setUserIdHeader(userId)

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            APIClient.shared.setAppVersionHeader(appVersion)
        }
        if let bundleId = Bundle.main.bundleIdentifier {
            APIClient.shared.setBundleIdHeader(bundleId)
        }

        // Start StoreKit observation
        StoreKitManager.shared.startObserving(useStoreKit2: useStoreKit2)

        // Send receipt (in background)
        Task {
            await StoreKitManager.shared.sendReceipt()
        }

        // API initialization
        let initResponse = try await APIRequests.initialize(sdkKey: sdkKey)

        // Store organization ID and calculate server-client time offset
        self.organizationId = initResponse.organizationId
        let clientTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
        self.serverTimeOffset = initResponse.serverTimestamp - clientTimestamp

        // Initialization complete
        isInitialized = true

        // Process pending events
        await processPendingEvents()

        return InitializeResult(
            organizationId: initResponse.organizationId,
            platform: initResponse.platform,
            version: initResponse.version,
            userId: userId
        )
    }

    /// Log event (using LogEventOptions)
    /// - Parameter options: Event options to log
    @MainActor
    public func logEvent(_ options: LogEventOptions) async {
        guard let sdkKey = sdkKey, let userId = userId else {
            // Add to queue if SDK is not initialized
            pendingEvents.append(.logEvent(PendingCustomEvent(
                eventName: options.eventName,
                params: options.params,
                clientTimestamp: Date().timeIntervalSince1970 * 1000
            )))
            return
        }

        do {
            try await APIRequests.createEvent(
                sdkKey: sdkKey,
                userId: userId,
                eventName: options.eventName,
                params: options.params
            )
        } catch {
            print("[MonetaiSDK] Event logging failed: \(options.eventName), error: \(error)")
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

    /// Log a product view event for dynamic pricing feedback
    /// - Parameter params: Product view parameters
    @MainActor
    public func logViewProductItem(_ params: ViewProductItemParams) async {
        guard let sdkKey = sdkKey, let userId = userId else {
            // Add to queue if SDK is not initialized
            pendingEvents.append(.viewProductItem(PendingViewProductItemEvent(
                params: params,
                clientTimestamp: Date().timeIntervalSince1970 * 1000
            )))
            return
        }

        do {
            try await APIRequests.createViewProductItemEvent(
                sdkKey: sdkKey,
                userId: userId,
                params: params
            )
        } catch {
            print("[MonetaiSDK] View product item event failed: \(error)")
        }
    }

    /// Get a dynamic pricing offer for a specific promotion
    /// - Parameter placement: Placement identifier for the promotion
    /// - Returns: Offer with agent info and products, or nil if no match
    @MainActor
    public func getOffer(placement: String) async throws -> Offer? {
        guard let sdkKey = sdkKey, let userId = userId else {
            throw MonetaiError.notInitialized
        }

        return try await APIRequests.getOffer(
            sdkKey: sdkKey,
            userId: userId,
            placement: placement
        )
    }

    /// Reset SDK
    @MainActor
    @objc public func reset() {
        sdkKey = nil
        userId = nil
        organizationId = 0
        isInitialized = false
        pendingEvents.removeAll()
        serverTimeOffset = 0

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

    // MARK: - Objective-C Compatible Methods

    /// Initialize MonetaiSDK (Objective-C compatible)
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

    /// Log event (Objective-C compatible)
    @objc public func logEventWithEventName(_ eventName: String, params: [String: Any]? = nil) {
        Task {
            await logEvent(eventName: eventName, params: params)
        }
    }

    /// Log view product item event (Objective-C compatible)
    @objc public func logViewProductItemWithParams(_ params: ViewProductItemParams) {
        Task {
            await logViewProductItem(params)
        }
    }

    /// Get offer (Objective-C compatible)
    @objc public func getOfferWithPlacement(_ placement: String, completion: @escaping (Offer?, Error?) -> Void) {
        Task {
            do {
                let offer = try await getOffer(placement: placement)
                completion(offer, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    // MARK: - Private Methods

    private func processPendingEvents() async {
        guard let sdkKey = sdkKey, let userId = userId else { return }

        let events = pendingEvents
        pendingEvents.removeAll()

        if events.isEmpty {
            return
        }

        for event in events {
            do {
                switch event {
                case .logEvent(let customEvent):
                    let adjustedTimestamp = customEvent.clientTimestamp + Double(serverTimeOffset)
                    let createdAt = Date(timeIntervalSince1970: adjustedTimestamp / 1000)

                    try await APIRequests.createEvent(
                        sdkKey: sdkKey,
                        userId: userId,
                        eventName: customEvent.eventName,
                        params: customEvent.params,
                        createdAt: createdAt
                    )

                case .viewProductItem(let viewEvent):
                    let adjustedTimestamp = viewEvent.clientTimestamp + Double(serverTimeOffset)
                    let createdAt = Date(timeIntervalSince1970: adjustedTimestamp / 1000)

                    try await APIRequests.createViewProductItemEvent(
                        sdkKey: sdkKey,
                        userId: userId,
                        params: viewEvent.params,
                        createdAt: createdAt
                    )
                }
            } catch {
                print("[MonetaiSDK] Pending event processing failed: \(error)")
            }
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

    public init(organizationId: Int, platform: String, version: String, userId: String) {
        self.organizationId = organizationId
        self.platform = platform
        self.version = version
        self.userId = userId
        super.init()
    }

    public override var description: String {
        return "InitializeResult(organizationId: \(organizationId), platform: \"\(platform)\", version: \"\(version)\", userId: \"\(userId)\")"
    }
}
