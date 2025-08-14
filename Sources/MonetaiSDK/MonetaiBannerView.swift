import UIKit
import WebKit

/// Banner displays discount information via WKWebView and sends CLICK_BANNER on tap
@objc public class MonetaiBannerView: UIView, WKScriptMessageHandler, WKNavigationDelegate {
    private var onPaywall: (() -> Void)?
    private var bannerParams: BannerParams?
    private var webView: WKWebView!
    private var loadingIndicator: UIActivityIndicatorView!
    private var hasWebViewError = false

    private var paywallBaseURL: String { MonetaiSDKConstants.webBaseURL + "/banner" }
    private var webViewUserAgent: String { MonetaiSDKConstants.webViewUserAgent }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }

    @objc public func configure(bannerParams: BannerParams, onPaywall: @escaping () -> Void) {
        self.bannerParams = bannerParams
        self.onPaywall = onPaywall
        loadBanner()
    }

    private func setupWebView() {
        clipsToBounds = false
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1

        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        // Inject RN-style bridge so web can call window.ReactNativeWebView.postMessage(...)
        let bridgeJS = "window.ReactNativeWebView = { postMessage: function(message) { window.webkit.messageHandlers.ReactNativeWebView.postMessage(message); } }"
        let bridgeScript = WKUserScript(source: bridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(bridgeScript)
        contentController.add(self, name: "ReactNativeWebView")
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.customUserAgent = webViewUserAgent
        webView.translatesAutoresizingMaskIntoConstraints = false

        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(webView)
        addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func buildBannerURL() -> URL? {
        guard let params = bannerParams else { return nil }
        var components = URLComponents(string: "\(paywallBaseURL)/\(params.style.stringValue)")
        var query: [URLQueryItem] = []
        query.append(URLQueryItem(name: "discount", value: String(params.discountPercent)))
        query.append(URLQueryItem(name: "locale", value: params.locale))
        let isoFormatter = ISO8601DateFormatter()
        query.append(URLQueryItem(name: "endedAt", value: isoFormatter.string(from: params.endedAt)))
        components?.queryItems = query
        return components?.url
    }

    private func loadBanner() {
        guard let url = buildBannerURL() else { return }
        hasWebViewError = false
        loadingIndicator.startAnimating()
        webView.load(URLRequest(url: url))
    }

    // MARK: - WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Expecting messages via window.ReactNativeWebView.postMessage
        if message.name == "ReactNativeWebView" {
            if let data = message.body as? String, data == "CLICK_BANNER" {
                onPaywall?()
            }
        }
    }

    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        hasWebViewError = true
        isHidden = true
    }
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        hasWebViewError = true
        isHidden = true
    }
}


