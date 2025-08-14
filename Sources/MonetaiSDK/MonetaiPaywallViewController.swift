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
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // Setup WebView
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = webViewUserAgent
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .systemBlue
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Paywall Loading
    
    private func loadPaywall() {
        let url = buildPaywallURL()
        let request = URLRequest(url: url)
        
        loadingIndicator.startAnimating()
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
        
        return components.url!
    }
    
    // MARK: - Actions
    
    @objc private func handleBackgroundTap() {
        onClose?()
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

extension MonetaiPaywallViewController: WKNavigationDelegate {
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


