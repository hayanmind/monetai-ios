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
    // Callbacks
    /// Unified purchase callback. SDK provides a close handler to dismiss the paywall when appropriate.
    @objc public var onPurchase: (((@escaping () -> Void) -> Void))?
    @objc public var onTermsOfService: (() -> Void)?
    @objc public var onPrivacyPolicy: (() -> Void)?

    @objc public override init() {
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

    @objc public init(
        discountPercent: String,
        endedAt: String,
        regularPrice: String,
        discountedPrice: String,
        locale: String,
        features: [Feature],
        style: PaywallStyle
    ) {
        self.discountPercent = discountPercent
        self.endedAt = endedAt
        self.regularPrice = regularPrice
        self.discountedPrice = discountedPrice
        self.locale = locale
        self.features = features
        self.style = style
        super.init()
    }
}

// MARK: - Banner Parameters
@objc public class BannerParams: NSObject {
    @objc public let locale: String
    @objc public let discountPercent: Int
    @objc public let endedAt: Date
    @objc public let style: PaywallStyle
    @objc public let bottom: CGFloat

    @objc public init(
        locale: String,
        discountPercent: Int,
        endedAt: Date,
        style: PaywallStyle,
        bottom: CGFloat = 20
    ) {
        self.locale = locale
        self.discountPercent = discountPercent
        self.endedAt = endedAt
        self.style = style
        self.bottom = bottom
        super.init()
    }
}
