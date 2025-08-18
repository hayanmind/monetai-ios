import Foundation
import UIKit

/// Protocol for handling promotion expiration events
@objc public protocol MonetaiPromotionTimerDelegate: AnyObject {
    func promotionDidExpire()
}

/// Manages promotion expiration timing with battery-optimized timer management
@objc public class MonetaiPromotionTimer: NSObject {
    
    // MARK: - Properties
    private weak var delegate: MonetaiPromotionTimerDelegate?
    private var expirationTimer: Timer?
    private var isTimerActive = false
    private var discountInfo: DiscountInfo?
    
    // MARK: - Initialization
    public init(delegate: MonetaiPromotionTimerDelegate) {
        self.delegate = delegate
        super.init()
        setupAppLifecycleObservers()
    }
    
    deinit {
        cleanupObservers()
        stopExpirationTimer()
    }
    
    // MARK: - Public Methods
    
    /// Configure the manager with discount information
    /// - Parameter discountInfo: Discount information containing expiration time
    public func configure(discountInfo: DiscountInfo) {
        self.discountInfo = discountInfo
        startExpirationTimerIfNeeded()
    }
    
    /// Start monitoring promotion expiration
    public func startMonitoring() {
        startExpirationTimerIfNeeded()
    }
    
    /// Stop monitoring promotion expiration
    public func stopMonitoring() {
        stopExpirationTimer()
    }
    
    /// Check if promotion has expired
    public func checkExpiration() {
        checkPromotionExpiration()
    }
    
    // MARK: - App Lifecycle Setup
    private func setupAppLifecycleObservers() {
        // App becomes active - check promotion expiration and start timer if needed
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        // App goes to background - stop timer to save battery
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        // App enters foreground - check promotion expiration
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func cleanupObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - App Lifecycle Handlers
    @objc private func appDidBecomeActive() {
        checkPromotionExpiration()
        startExpirationTimerIfNeeded()
    }
    
    @objc private func appWillResignActive() {
        stopExpirationTimer()
    }
    
    @objc private func appWillEnterForeground() {
        checkPromotionExpiration()
        startExpirationTimerIfNeeded()
    }
    
    // MARK: - Promotion Expiration Management
    private func checkPromotionExpiration() {
        guard let discountInfo = discountInfo else { return }
        
        let now = Date()
        if now >= discountInfo.endedAt {
            // Promotion has expired, notify delegate
            print("[MonetaiSDK] Promotion expired, notifying delegate")
            delegate?.promotionDidExpire()
        }
    }
    
    private func startExpirationTimerIfNeeded() {
        guard let discountInfo = discountInfo else { return }
        
        let timeUntilExpiration = discountInfo.endedAt.timeIntervalSinceNow
        
        if timeUntilExpiration <= 0 {
            // Promotion already expired
            return
        }
        
        startExpirationTimer()
    }
    
    private func startExpirationTimer() {
        // Stop existing timer if running
        stopExpirationTimer()
        
        print("[MonetaiSDK] Starting expiration timer with 1 second interval")
        
        // Create timer with weak self to prevent retain cycles
        expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkPromotionExpiration()
        }
        
        isTimerActive = true
    }
    
    private func stopExpirationTimer() {
        if let timer = expirationTimer {
            timer.invalidate()
            expirationTimer = nil
            isTimerActive = false
            print("[MonetaiSDK] Expiration timer stopped")
        }
    }
}