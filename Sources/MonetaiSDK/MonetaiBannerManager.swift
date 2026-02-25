import Foundation
import Combine
import UIKit

/// BannerManager handles the display and management of banner UI
@objc public class MonetaiBannerManager: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published public private(set) var bannerVisible: Bool = false
    @Published public private(set) var bannerParams: BannerParams?

    // MARK: - Private Properties
    private weak var bannerView: MonetaiBannerView?
    private weak var paywallManager: MonetaiPaywallManager?

    // MARK: - Public Methods

    /// Configure banner with parameters and paywall manager
    /// - Parameters:
    ///   - bannerParams: Banner display parameters
    ///   - paywallManager: Paywall manager reference for banner interactions
    @objc public func configure(bannerParams: BannerParams, paywallManager: MonetaiPaywallManager) {
        self.bannerParams = bannerParams
        self.paywallManager = paywallManager
    }

    /// Show banner
    @objc public func showBanner() {
        guard let bannerParams = bannerParams else {
            return
        }

        DispatchQueue.main.async {
            if let existing = self.bannerView {
                existing.configure(bannerParams: bannerParams) {
                    self.paywallManager?.showPaywall()
                }
                self.bannerVisible = true
                self.paywallManager?.preloadPaywall()
                return
            }

            guard let containerView = self.findContainerView() else {
                return
            }

            let banner = MonetaiBannerView()
            banner.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(banner)

            let bannerHeight: CGFloat
            switch bannerParams.style {
            case .textFocused:
                bannerHeight = 45
            case .compact:
                bannerHeight = 68
            case .keyFeatureSummary, .highlightBenefits:
                bannerHeight = 56
            }

            NSLayoutConstraint.activate([
                banner.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                banner.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                banner.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -bannerParams.bottom),
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

            self.paywallManager?.preloadPaywall()
        }
    }

    /// Hide banner
    @objc public func hideBanner() {
        DispatchQueue.main.async {
            self.bannerVisible = false
            if let banner = self.bannerView {
                self.bannerView = nil
                UIView.animate(withDuration: 0.2, animations: {
                    banner.alpha = 0
                    banner.transform = CGAffineTransform(translationX: 0, y: 20)
                }, completion: { _ in
                    banner.removeFromSuperview()
                })
            }
        }
    }

    // MARK: - Private Methods

    private func findContainerView() -> UIView? {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
                var topVC = keyWindow.rootViewController
                while let presented = topVC?.presentedViewController { topVC = presented }
                return topVC?.view ?? keyWindow
            }
        }
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first {
            var topVC = window.rootViewController
            while let presented = topVC?.presentedViewController { topVC = presented }
            return topVC?.view ?? window
        }
        return nil
    }
}
