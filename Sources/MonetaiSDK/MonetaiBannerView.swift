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
        
        // Set corner radius based on style
        let cornerRadius: CGFloat
        switch bannerParams.style {
        case .textFocused:
            cornerRadius = 12
        case .compact:
            cornerRadius = 16
        case .keyFeatureSummary:
            cornerRadius = 16
        case .highlightBenefits:
            cornerRadius = 12
        default:
            cornerRadius = 12
        }
        
        // Apply corner radius only to WebView
        webView.layer.cornerRadius = cornerRadius
        
        // Enable corner radius clipping for WebView content
        webView.clipsToBounds = true
        
        // Ensure corner radius is visible while keeping shadow
        layer.masksToBounds = false
        
        loadBanner()
    }

    private func setupWebView() {
        // Set background to transparent
        backgroundColor = .clear
        
        // Corner radius will be set dynamically based on style in configure method
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1

        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        // Use native 'monetai' channel for messaging
        contentController.add(self, name: "monetai")
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        // Append SDK UA token to existing UA for server-side validation
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, _ in
            if let self = self, let ua = result as? String {
                self.webView.customUserAgent = ua + " " + self.webViewUserAgent
                print("[MonetaiSDK] Banner WebView UA set: \(self.webView.customUserAgent ?? "")")
            } else {
                self?.webView.customUserAgent = self?.webViewUserAgent
                if let ua = self?.webView.customUserAgent {
                    print("[MonetaiSDK] Banner WebView UA fallback set: \(ua)")
                }
            }
        }
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
        print("[MonetaiSDK] Loading banner URL: \(url.absoluteString)")
        webView.load(URLRequest(url: url))
    }

    // MARK: - WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "monetai" else { return }
        guard let data = message.body as? String else {
            print("[MonetaiSDK] Banner WebView message: non-string body received")
            return
        }
        print("[MonetaiSDK] Banner WebView message received: name=\(message.name), action=\(data)")
        switch data {
        case "CLICK_BANNER":
            onPaywall?()
        default:
            break
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


