import UIKit
import WebKit

/// PaywallViewController displays the paywall using WebView
@objc public class MonetaiPaywallViewController: UIViewController {
    
    // MARK: - Properties
    private var paywallParams: PaywallParams
    private var onClose: (() -> Void)?
    private var onPurchase: (() -> Void)?
    private var onTermsOfService: (() -> Void)?
    private var onPrivacyPolicy: (() -> Void)?
    
    private var webView: WKWebView!
    private var loadingIndicator: UIActivityIndicatorView!
    private var errorView: UIView?
    private var dimBackgroundView: UIView!
    
    // MARK: - Constants
    private var paywallBaseURL: String { MonetaiSDKConstants.webBaseURL + "/paywall" }
    private var webViewUserAgent: String { MonetaiSDKConstants.webViewUserAgent }
    
    // MARK: - Initialization
    
    @objc public init(
        paywallParams: PaywallParams,
        onClose: (() -> Void)? = nil,
        onPurchase: (() -> Void)? = nil,
        onTermsOfService: (() -> Void)? = nil,
        onPrivacyPolicy: (() -> Void)? = nil
    ) {
        self.paywallParams = paywallParams
        self.onClose = onClose
        self.onPurchase = onPurchase
        self.onTermsOfService = onTermsOfService
        self.onPrivacyPolicy = onPrivacyPolicy
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPaywall()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // For compact style, ensure dim background is visible immediately
        if paywallParams.style == .compact {
            dimBackgroundView.alpha = 1.0
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // For compact style, animate WebView from bottom
        if paywallParams.style == .compact {
            webView.transform = CGAffineTransform(translationX: 0, y: 372)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.webView.alpha = 1.0
                self.webView.transform = .identity
            }
        }
    }
    
    deinit {
        // Remove message handler to avoid retain cycles
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "ReactNativeWebView")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Set main view background to clear
        view.backgroundColor = UIColor.clear
        
        // Setup dim background view
        dimBackgroundView = UIView()
        dimBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup WebView
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        // Use native 'monetai' channel for messaging
        let contentController = WKUserContentController()
        contentController.add(self, name: "monetai")
        print("[MonetaiSDK] Paywall WebView: registered message handler 'monetai'")
        webViewConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        webView.uiDelegate = self
        // Append SDK UA token to existing UA for server-side validation
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, _ in
            if let self = self, let ua = result as? String {
                self.webView.customUserAgent = ua + " " + self.webViewUserAgent
                print("[MonetaiSDK] Paywall WebView UA set: \(self.webView.customUserAgent ?? "")")
            } else {
                self?.webView.customUserAgent = self?.webViewUserAgent
                if let ua = self?.webView.customUserAgent {
                    print("[MonetaiSDK] Paywall WebView UA fallback set: \(ua)")
                }
            }
        }
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Apply corner radius for compact style
        if paywallParams.style == .compact {
            webView.layer.cornerRadius = 12
            webView.layer.masksToBounds = true
            // Initially hide WebView for compact style to animate it in
            webView.alpha = 0
        }
        
        // Setup loading indicator - same as banner
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        view.addSubview(dimBackgroundView)
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
        
        // Setup constraints based on style
        if paywallParams.style == .compact {
            // Compact style: fixed height 372, attached to bottom
            NSLayoutConstraint.activate([
                // Dim background covers entire screen
                dimBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                dimBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dimBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                dimBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                // WebView positioned at bottom
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.heightAnchor.constraint(equalToConstant: 372),
                
                loadingIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
            ])
        } else {
            // Other styles: full screen coverage
            NSLayoutConstraint.activate([
                // Dim background covers entire screen
                dimBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                dimBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dimBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                dimBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                // WebView covers entire screen
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        // Add tap gesture to dismiss for all styles
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Paywall Loading
    
    private func loadPaywall() {
        let url = buildPaywallURL()
        let request = URLRequest(url: url)
        
        loadingIndicator.startAnimating()
        print("[MonetaiSDK] Loading paywall started")
        webView.load(request)
    }
    
    private func buildPaywallURL() -> URL {
        var components = URLComponents(string: "\(paywallBaseURL)/\(paywallParams.style.stringValue)")!
        
        var queryItems: [URLQueryItem] = []
        
        if !paywallParams.discountPercent.isEmpty {
            queryItems.append(URLQueryItem(name: "discount", value: paywallParams.discountPercent))
        }
        
        if !paywallParams.endedAt.isEmpty {
            queryItems.append(URLQueryItem(name: "endedAt", value: paywallParams.endedAt))
        }
        
        if !paywallParams.regularPrice.isEmpty {
            queryItems.append(URLQueryItem(name: "regularPrice", value: paywallParams.regularPrice))
        }
        
        if !paywallParams.discountedPrice.isEmpty {
            queryItems.append(URLQueryItem(name: "discountedPrice", value: paywallParams.discountedPrice))
        }
        
        if !paywallParams.locale.isEmpty {
            queryItems.append(URLQueryItem(name: "locale", value: paywallParams.locale))
        }
        
        if !paywallParams.features.isEmpty {
            let featuresData = try? JSONSerialization.data(withJSONObject: paywallParams.features.map { feature in
                [
                    "title": feature.title,
                    "description": feature.featureDescription,
                    "isPremiumOnly": feature.isPremiumOnly
                ]
            })
            if let featuresData = featuresData,
               let featuresString = String(data: featuresData, encoding: .utf8) {
                queryItems.append(URLQueryItem(name: "features", value: featuresString))
            }
        }
        
        components.queryItems = queryItems
        
        let built = components.url!
        return built
    }
    
    // MARK: - Actions
    
    @objc private func handleBackgroundTap() {
        dismiss(animated: true) { [weak self] in
            self?.onClose?()
        }
    }
    
    // MARK: - Error Handling
    
    private func showError() {
        let errorView = UIView()
        errorView.backgroundColor = UIColor.systemBackground
        errorView.layer.cornerRadius = 12
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        let errorLabel = UILabel()
        errorLabel.text = "Failed to load paywall"
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = UIColor.systemBlue
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.addTarget(self, action: #selector(handleBackgroundTap), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        errorView.addSubview(errorLabel)
        errorView.addSubview(closeButton)
        
        view.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            errorLabel.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -16),
            
            closeButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        self.errorView = errorView
    }
}

// MARK: - WKNavigationDelegate

extension MonetaiPaywallViewController: WKNavigationDelegate, WKScriptMessageHandler {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        showError()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        showError()
    }

    // MARK: - WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "monetai" else { return }
        guard let action = message.body as? String else {
            print("[MonetaiSDK] Paywall WebView message: non-string body received")
            return
        }
        
        switch action {
        case "CLICK_PURCHASE_BUTTON":
            print("[MonetaiSDK] Action: CLICK_PURCHASE_BUTTON → onPurchase()")
            onPurchase?()
        case "CLICK_CLOSE_BUTTON":
            print("[MonetaiSDK] Action: CLICK_CLOSE_BUTTON → onClose()")
            onClose?()
        case "CLICK_TERMS_OF_SERVICE":
            print("[MonetaiSDK] Action: CLICK_TERMS_OF_SERVICE → onTermsOfService()")
            onTermsOfService?()
        case "CLICK_PRIVACY_POLICY":
            print("[MonetaiSDK] Action: CLICK_PRIVACY_POLICY → onPrivacyPolicy()")
            onPrivacyPolicy?()
        default:
            print("[MonetaiSDK] Unknown paywall action: \(action)")
        }
    }
}

// MARK: - WKUIDelegate

extension MonetaiPaywallViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        present(alert, animated: true)
    }
}


