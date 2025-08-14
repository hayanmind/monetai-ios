import Foundation
import Combine
import UIKit

/// PaywallManager handles the display and management of paywall UI
@objc public class MonetaiPaywallManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published public private(set) var paywallVisible: Bool = false
    @Published public private(set) var paywallParams: PaywallParams?
    
    // MARK: - Private Properties
    private var paywallConfig: PaywallConfig?
    private var discountInfo: DiscountInfo?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// Configure paywall with configuration and discount info
    /// - Parameters:
    ///   - paywallConfig: Paywall configuration
    ///   - discountInfo: Discount information
    @objc public func configure(paywallConfig: PaywallConfig, discountInfo: DiscountInfo?) {
        self.paywallConfig = paywallConfig
        self.discountInfo = discountInfo
        
        updatePaywallParams()
    }
    
    /// Show paywall
    @objc public func showPaywall() {
        guard paywallParams != nil else {
            print("[MonetaiSDK] PaywallManager: Cannot show paywall - paywallParams is null (data not ready)")
            return
        }
        
        DispatchQueue.main.async {
            self.paywallVisible = true
        }
    }
    
    /// Hide paywall
    @objc public func hidePaywall() {
        DispatchQueue.main.async {
            self.paywallVisible = false
        }
    }
    
    /// Handle purchase action
    @objc public func handlePurchase() {
        paywallConfig?.onPurchase?()
        hidePaywall()
    }
    
    /// Handle terms of service action
    @objc public func handleTermsOfService() {
        paywallConfig?.onTermsOfService?()
    }
    
    /// Handle privacy policy action
    @objc public func handlePrivacyPolicy() {
        paywallConfig?.onPrivacyPolicy?()
    }
    
    // MARK: - Private Methods
    
    private func updatePaywallParams() {
        guard let paywallConfig = paywallConfig,
              let discountInfo = discountInfo else {
            paywallParams = nil
            return
        }
        
        let paywallZ = paywallConfig.paywallZIndex
        let paywallElevation = paywallConfig.paywallElevation
        
        let params = PaywallParams(
            discountPercent: paywallConfig.discountPercent.description,
            endedAt: discountInfo.endedAt.ISO8601String(),
            regularPrice: paywallConfig.regularPrice,
            discountedPrice: paywallConfig.discountedPrice,
            locale: paywallConfig.locale,
            features: paywallConfig.features,
            style: paywallConfig.style,
            zIndex: paywallZ,
            elevation: paywallElevation
        )
        
        paywallParams = params
    }
}

// MARK: - Date Extension
private extension Date {
    func ISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}


