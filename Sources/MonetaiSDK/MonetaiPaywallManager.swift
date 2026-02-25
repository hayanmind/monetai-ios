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
    private var cancellables = Set<AnyCancellable>()
    private var currentPaywallViewController: MonetaiPaywallViewController?

    // MARK: - Public Methods

    /// Preload paywall WebView offscreen for faster first presentation
    @objc public func preloadPaywall() {
        DispatchQueue.main.async {
            guard let paywallParams = self.paywallParams else {
                return
            }
            if let existing = self.currentPaywallViewController {
                if existing.presentingViewController != nil {
                    return
                }
                return
            }
            let paywallVC = self.makePaywallViewController(paywallParams: paywallParams)
            _ = paywallVC.view
            self.currentPaywallViewController = paywallVC
        }
    }

    /// Clear preloaded paywall instance to free memory or reflect parameter changes
    @objc public func clearPreloadedPaywall() {
        if let vc = currentPaywallViewController, vc.presentingViewController != nil {
            return
        }
        currentPaywallViewController = nil
    }

    /// Configure paywall with configuration and parameters
    /// - Parameters:
    ///   - paywallConfig: Paywall configuration
    ///   - paywallParams: Paywall display parameters
    @objc public func configure(paywallConfig: PaywallConfig, paywallParams: PaywallParams) {
        self.paywallConfig = paywallConfig
        self.paywallParams = paywallParams

        clearPreloadedPaywall()
    }

    /// Show paywall
    @objc public func showPaywall() {
        guard paywallParams != nil else {
            return
        }

        DispatchQueue.main.async {
            self.paywallVisible = true
            self.presentPaywall()
        }
    }

    /// Hide paywall
    @objc public func hidePaywall() {
        DispatchQueue.main.async {
            self.paywallVisible = false
            self.dismissPaywall()
        }
    }

    /// Handle purchase action
    @objc public func handlePurchase() {
        if let onPurchase = paywallConfig?.onPurchase {
            DispatchQueue.main.async {
                onPurchase {
                    self.hidePaywall()
                }
            }
        }
    }

    /// Handle terms of service action
    @objc public func handleTermsOfService() {
        if let onTos = paywallConfig?.onTermsOfService {
            DispatchQueue.main.async {
                onTos()
            }
        }
    }

    /// Handle privacy policy action
    @objc public func handlePrivacyPolicy() {
        if let onPrivacy = paywallConfig?.onPrivacyPolicy {
            DispatchQueue.main.async {
                onPrivacy()
            }
        }
    }

    // MARK: - Private Methods

    // MARK: - Paywall Presentation
    private func presentPaywall() {
        guard let paywallParams = paywallParams else {
            return
        }
        guard let presentingVC = findTopViewController() else {
            return
        }
        if let presented = presentingVC.presentedViewController, presented is MonetaiPaywallViewController {
            return
        }
        let paywallVC: MonetaiPaywallViewController = {
            if let preloaded = currentPaywallViewController {
                configurePresentationStyle(for: preloaded, style: paywallParams.style)
                return preloaded
            }
            return makePaywallViewController(paywallParams: paywallParams)
        }()

        presentingVC.present(paywallVC, animated: true)
        currentPaywallViewController = paywallVC
    }

    private func dismissPaywall() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let paywallVC = self.currentPaywallViewController {
                paywallVC.dismiss(animated: true)
                return
            }
            if let presentingVC = self.findTopViewController(),
               let presented = presentingVC.presentedViewController as? MonetaiPaywallViewController {
                presented.dismiss(animated: true)
            }
        }
    }

    private func findTopViewController() -> UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
                var topVC = keyWindow.rootViewController
                while let presented = topVC?.presentedViewController { topVC = presented }
                return topVC
            }
        }
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first {
            var topVC = window.rootViewController
            while let presented = topVC?.presentedViewController { topVC = presented }
            return topVC
        }
        return nil
    }

    // MARK: - Helpers (Paywall VC construction)
    private func makePaywallViewController(paywallParams: PaywallParams) -> MonetaiPaywallViewController {
        let vc = MonetaiPaywallViewController(
            paywallParams: paywallParams,
            onClose: { [weak self] in
                self?.hidePaywall()
            },
            onPurchase: { [weak self] in
                self?.handlePurchase()
            },
            onTermsOfService: { [weak self] in
                self?.handleTermsOfService()
            },
            onPrivacyPolicy: { [weak self] in
                self?.handlePrivacyPolicy()
            }
        )
        configurePresentationStyle(for: vc, style: paywallParams.style)
        return vc
    }

    private func configurePresentationStyle(for viewController: UIViewController, style: PaywallStyle) {
        if style == .compact {
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.modalTransitionStyle = .crossDissolve
        } else {
            viewController.modalPresentationStyle = .overFullScreen
            viewController.modalTransitionStyle = .crossDissolve
        }
    }
}

// MARK: - Date Extension
private extension Date {
    func ISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
