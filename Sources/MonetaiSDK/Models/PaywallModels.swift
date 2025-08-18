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
    // Banner related
    @objc public let enabled: Bool
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
        locale: String,
        style: PaywallStyle,
        features: [Feature] = [],
        // Banner defaults align with RN SDK
        enabled: Bool = true,
        bannerBottom: CGFloat = 20
    ) {
        self.discountPercent = discountPercent
        self.regularPrice = regularPrice
        self.discountedPrice = discountedPrice
        self.locale = locale
        self.style = style
        self.features = features
        self.enabled = enabled
        self.bannerBottom = bannerBottom
        super.init()
    }
    
    // MARK: - Objective-C Convenience Initializer
    
    /// Options-based convenience initializer for Objective-C
    @objc public convenience init(
        discountPercent: Int,
        regularPrice: String,
        discountedPrice: String,
        locale: String,
        style: PaywallStyle,
        options: PaywallConfigOptions?
    ) {
        self.init(
            discountPercent: discountPercent,
            regularPrice: regularPrice,
            discountedPrice: discountedPrice,
            locale: locale,
            style: style,
            features: options?.features ?? [],
            enabled: options?.enabled?.boolValue ?? true,
            bannerBottom: options?.bannerBottom.map { CGFloat(truncating: $0) } ?? 20
        )
    }
}

// MARK: - Paywall Configuration Options

/// Options class for flexible PaywallConfig initialization in Objective-C
@objcMembers
public class PaywallConfigOptions: NSObject {
    public var features: [Feature]?
    public var enabled: NSNumber?
    public var bannerBottom: NSNumber?   // CGFloat? 대신 NSNumber?로
    
    public override init() { 
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

// MARK: - Banner Parameters (to mirror RN BannerParams)
@objc public class BannerParams: NSObject {
    @objc public let enabled: Bool
    @objc public let locale: String
    @objc public let discountPercent: Int
    @objc public let endedAt: Date
    @objc public let style: PaywallStyle
    @objc public let bottom: CGFloat

    @objc public init(
        enabled: Bool,
        locale: String,
        discountPercent: Int,
        endedAt: Date,
        style: PaywallStyle,
        bottom: CGFloat = 20
    ) {
        self.enabled = enabled
        self.locale = locale
        self.discountPercent = discountPercent
        self.endedAt = endedAt
        self.style = style
        self.bottom = bottom
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
