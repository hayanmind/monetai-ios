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
    private var currentPaywallViewController: MonetaiPaywallViewController?
    
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
            // Ensure UI-affecting callbacks run on main thread
            DispatchQueue.main.async {
                onPurchase {
                    // Ensure actual modal dismissal via SDK entry point
                    self.hidePaywall()
                }
            }
        } else {
            print("[MonetaiSDK] onPurchase callback not set.")
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
    
    // MARK: - Paywall Presentation
    private func presentPaywall() {
        guard let paywallParams = paywallParams else {
            print("[MonetaiSDK] Auto present paywall skipped - paywallParams is null")
            return
        }
        guard let presentingVC = findTopViewController() else {
            print("[MonetaiSDK] Auto present paywall skipped - cannot find top view controller")
            return
        }
        // Avoid double-present
        if let presented = presentingVC.presentedViewController, presented is MonetaiPaywallViewController {
            print("[MonetaiSDK] Paywall already presented")
            return
        }
        let paywallVC = MonetaiPaywallViewController(
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
        
        // Set modal presentation style based on paywall style
        if paywallParams.style == .compact {
            paywallVC.modalPresentationStyle = .overCurrentContext
            paywallVC.modalTransitionStyle = .crossDissolve
        } else {
            paywallVC.modalPresentationStyle = .overFullScreen
            paywallVC.modalTransitionStyle = .crossDissolve
        }
        print("[MonetaiSDK] Presenting paywall automatically")
        presentingVC.present(paywallVC, animated: true)
        currentPaywallViewController = paywallVC
    }

    private func dismissPaywall() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let paywallVC = self.currentPaywallViewController {
                print("[MonetaiSDK] Dismissing presented paywall via stored reference")
                paywallVC.dismiss(animated: true) {
                    self.currentPaywallViewController = nil
                }
                return
            }
            // Fallback: try to find by hierarchy
            if let presentingVC = self.findTopViewController(),
               let presented = presentingVC.presentedViewController as? MonetaiPaywallViewController {
                print("[MonetaiSDK] Dismissing presented paywall via hierarchy lookup")
                presented.dismiss(animated: true) {
                    self.currentPaywallViewController = nil
                }
            }
        }
    }
    
    private func findTopViewController() -> UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
                // Prefer the top-most presented VC's view if available
                var topVC = keyWindow.rootViewController
                while let presented = topVC?.presentedViewController { topVC = presented }
                return topVC
            }
        }
        // Fallback for older APIs
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first {
            var topVC = window.rootViewController
            while let presented = topVC?.presentedViewController { topVC = presented }
            return topVC
        }
        return nil
    }
}

// MARK: - Date Extension
private extension Date {
    func ISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}


