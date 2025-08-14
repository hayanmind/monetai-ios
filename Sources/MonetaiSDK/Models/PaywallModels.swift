import Foundation
import CoreGraphics

// MARK: - Paywall Style Types
@objc public enum PaywallStyle: Int, CaseIterable {
    case compact = 0
    case highlightBenefits = 1
    case keyFeatureSummary = 2
    case textFocused = 3
    
    public var stringValue: String {
        switch self {
        case .compact:
            return "compact"
        case .highlightBenefits:
            return "highlight-benefits"
        case .keyFeatureSummary:
            return "key-feature-summary"
        case .textFocused:
            return "text-focused"
        }
    }
}

// MARK: - Feature Model
@objc public class Feature: NSObject {
    @objc public let title: String
    @objc public let featureDescription: String
    @objc public let isPremiumOnly: Bool
    
    @objc public init(title: String, description: String, isPremiumOnly: Bool = false) {
        self.title = title
        self.featureDescription = description
        self.isPremiumOnly = isPremiumOnly
        super.init()
    }
}

// MARK: - Paywall Configuration
@objc public class PaywallConfig: NSObject {
    @objc public let discountPercent: Int
    @objc public let regularPrice: String
    @objc public let discountedPrice: String
    @objc public let locale: String
    @objc public let features: [Feature]
    @objc public let style: PaywallStyle
    @objc public let paywallZIndex: Int
    @objc public let paywallElevation: Int
    // Banner related
    @objc public let enabled: Bool
    @objc public let isSubscriber: Bool
    @objc public let bannerZIndex: Int
    @objc public let bannerElevation: Int
    @objc public let bannerBottom: CGFloat
    
    // Callbacks
    /// Unified purchase callback. SDK provides a close handler to dismiss the paywall when appropriate.
    @objc public var onPurchase: (((@escaping () -> Void) -> Void))?
    @objc public var onTermsOfService: (() -> Void)?
    @objc public var onPrivacyPolicy: (() -> Void)?
    
    @objc public init(
        discountPercent: Int,
        regularPrice: String,
        discountedPrice: String,
        locale: String = "en",
        features: [Feature] = [],
        style: PaywallStyle = .textFocused,
        paywallZIndex: Int = 2000,
        paywallElevation: Int = 16,
        // Banner defaults align with RN SDK
        enabled: Bool = true,
        isSubscriber: Bool = false,
        bannerZIndex: Int = 1000,
        bannerElevation: Int = 8,
        bannerBottom: CGFloat = 20
    ) {
        self.discountPercent = discountPercent
        self.regularPrice = regularPrice
        self.discountedPrice = discountedPrice
        self.locale = locale
        self.features = features
        self.style = style
        self.paywallZIndex = paywallZIndex
        self.paywallElevation = paywallElevation
        self.enabled = enabled
        self.isSubscriber = isSubscriber
        self.bannerZIndex = bannerZIndex
        self.bannerElevation = bannerElevation
        self.bannerBottom = bannerBottom
        super.init()
    }
}

// MARK: - Paywall Parameters
@objc public class PaywallParams: NSObject {
    @objc public let discountPercent: String
    @objc public let endedAt: String
    @objc public let regularPrice: String
    @objc public let discountedPrice: String
    @objc public let locale: String
    @objc public let features: [Feature]
    @objc public let style: PaywallStyle
    @objc public let zIndex: Int
    @objc public let elevation: Int
    
    @objc public init(
        discountPercent: String,
        endedAt: String,
        regularPrice: String,
        discountedPrice: String,
        locale: String,
        features: [Feature],
        style: PaywallStyle,
        zIndex: Int,
        elevation: Int
    ) {
        self.discountPercent = discountPercent
        self.endedAt = endedAt
        self.regularPrice = regularPrice
        self.discountedPrice = discountedPrice
        self.locale = locale
        self.features = features
        self.style = style
        self.zIndex = zIndex
        self.elevation = elevation
        super.init()
    }
}

// MARK: - Banner Parameters (to mirror RN BannerParams)
@objc public class BannerParams: NSObject {
    @objc public let enabled: Bool
    @objc public let isSubscriber: Bool
    @objc public let locale: String
    @objc public let discountPercent: Int
    @objc public let endedAt: Date
    @objc public let style: PaywallStyle
    @objc public let bottom: CGFloat
    @objc public let zIndex: Int
    @objc public let elevation: Int

    @objc public init(
        enabled: Bool,
        isSubscriber: Bool,
        locale: String,
        discountPercent: Int,
        endedAt: Date,
        style: PaywallStyle,
        bottom: CGFloat = 20,
        zIndex: Int = 1000,
        elevation: Int = 8
    ) {
        self.enabled = enabled
        self.isSubscriber = isSubscriber
        self.locale = locale
        self.discountPercent = discountPercent
        self.endedAt = endedAt
        self.style = style
        self.bottom = bottom
        self.zIndex = zIndex
        self.elevation = elevation
        super.init()
    }
}

// MARK: - Discount Info
@objc public class DiscountInfo: NSObject {
    @objc public let startedAt: Date
    @objc public let endedAt: Date
    @objc public let userId: String
    @objc public let sdkKey: String
    
    @objc public init(startedAt: Date, endedAt: Date, userId: String, sdkKey: String) {
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.userId = userId
        self.sdkKey = sdkKey
        super.init()
    }
}
