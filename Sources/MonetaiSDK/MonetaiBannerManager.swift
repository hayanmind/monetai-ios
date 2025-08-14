import Foundation
import Combine
import UIKit

/// BannerManager handles the display and management of banner UI
@objc public class MonetaiBannerManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published public private(set) var bannerVisible: Bool = false
    @Published public private(set) var bannerParams: BannerParams?
    
    // MARK: - Private Properties
    private var paywallConfig: PaywallConfig?
    private var discountInfo: DiscountInfo?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// Configure banner with configuration and discount info
    /// - Parameters:
    ///   - paywallConfig: Paywall configuration
    ///   - discountInfo: Discount information
    @objc public func configure(paywallConfig: PaywallConfig, discountInfo: DiscountInfo?) {
        self.paywallConfig = paywallConfig
        self.discountInfo = discountInfo
        
        updateBannerParams()
    }
    
    /// Show banner
    @objc public func showBanner() {
        guard bannerParams != nil else {
            print("[MonetaiSDK] BannerManager: Cannot show banner - bannerParams is null (data not ready)")
            return
        }
        
        DispatchQueue.main.async {
            self.bannerVisible = true
        }
    }
    
    /// Hide banner
    @objc public func hideBanner() {
        DispatchQueue.main.async {
            self.bannerVisible = false
        }
    }
    
    // MARK: - Private Methods
    
    private func updateBannerParams() {
        guard let paywallConfig = paywallConfig,
              let discountInfo = discountInfo else {
            bannerParams = nil
            return
        }

        let params = BannerParams(
            enabled: paywallConfig.enabled,
            isSubscriber: paywallConfig.isSubscriber,
            locale: paywallConfig.locale,
            discountPercent: paywallConfig.discountPercent,
            endedAt: discountInfo.endedAt,
            style: paywallConfig.style,
            bottom: paywallConfig.bannerBottom,
            zIndex: paywallConfig.bannerZIndex,
            elevation: paywallConfig.bannerElevation
        )
        bannerParams = params
    }
}


