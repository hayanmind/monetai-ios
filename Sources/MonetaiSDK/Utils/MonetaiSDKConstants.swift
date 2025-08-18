import Foundation

/// Global SDK constants and configuration
public enum MonetaiSDKConstants {
    /// Base URL for monetai web paywall/banner
    public static var webBaseURL: String = "https://dashboard.monetai.io/webview"

    /// User-Agent for SDK webviews
    public static var webViewUserAgent: String = "MonetaiSDK"
}

@available(*, deprecated, renamed: "MonetaiSDKConstants")
public typealias SDKConstants = MonetaiSDKConstants


