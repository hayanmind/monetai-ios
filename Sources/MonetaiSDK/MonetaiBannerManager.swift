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
    private weak var bannerView: MonetaiBannerView?
    private weak var paywallManager: MonetaiPaywallManager?
    
    // MARK: - Public Methods
    
    /// Configure banner with configuration and discount info
    /// - Parameters:
    ///   - paywallConfig: Paywall configuration
    ///   - discountInfo: Discount information
    ///   - paywallManager: Paywall manager reference for banner interactions
    @objc public func configure(paywallConfig: PaywallConfig, discountInfo: DiscountInfo?, paywallManager: MonetaiPaywallManager) {
        self.paywallConfig = paywallConfig
        self.discountInfo = discountInfo
        self.paywallManager = paywallManager
        
        updateBannerParams()
    }
    
    /// Show banner (SDK-controlled)
    @objc public func showBanner() {
        guard let bannerParams = bannerParams else {
            print("[MonetaiSDK] BannerManager: Cannot show banner - bannerParams is null (data not ready)")
            return
        }
        
        DispatchQueue.main.async {
            // If already visible, ensure it's configured with latest params
            if let existing = self.bannerView {
                existing.configure(bannerParams: bannerParams) {
                    self.paywallManager?.showPaywall()
                }
                self.bannerVisible = true
                return
            }
            
            guard let containerView = self.findContainerView() else {
                print("[MonetaiSDK] BannerManager: No active window/container to attach banner")
                return
            }
            
            let banner = MonetaiBannerView()
            banner.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(banner)
            
            // Set banner height based on style
            let bannerHeight: CGFloat
            switch bannerParams.style {
            case .textFocused:
                bannerHeight = 45
            case .compact:
                bannerHeight = 68
            default:
                bannerHeight = 56
            }
            
            NSLayoutConstraint.activate([
                banner.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                banner.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                banner.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -CGFloat(bannerParams.bottom)),
                banner.heightAnchor.constraint(equalToConstant: bannerHeight)
            ])
            
            banner.configure(bannerParams: bannerParams) {
                self.paywallManager?.showPaywall()
            }
            
            banner.alpha = 0
            banner.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(withDuration: 0.25) {
                banner.alpha = 1
                banner.transform = .identity
            }
            
            self.bannerView = banner
            self.bannerVisible = true
            print("[MonetaiSDK] BannerManager: Banner shown")
        }
    }
    
    /// Hide banner (SDK-controlled)
    @objc public func hideBanner() {
        DispatchQueue.main.async {
            if let banner = self.bannerView {
                UIView.animate(withDuration: 0.2, animations: {
                    banner.alpha = 0
                    banner.transform = CGAffineTransform(translationX: 0, y: 20)
                }, completion: { _ in
                    banner.removeFromSuperview()
                })
            }
            self.bannerView = nil
            self.bannerVisible = false
            print("[MonetaiSDK] BannerManager: Banner hidden")
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

    private func findContainerView() -> UIView? {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
                // Prefer the top-most presented VC's view if available
                var topVC = keyWindow.rootViewController
                while let presented = topVC?.presentedViewController { topVC = presented }
                return topVC?.view ?? keyWindow
            }
        }
        // Fallback for older APIs
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first {
            var topVC = window.rootViewController
            while let presented = topVC?.presentedViewController { topVC = presented }
            return topVC?.view ?? window
        }
        return nil
    }
}


