import Foundation

/// Parameters for logging a product view event
@objc public class ViewProductItemParams: NSObject {
    @objc public let productId: String
    @objc public let price: Double
    @objc public let regularPrice: Double
    @objc public let currencyCode: String
    @objc public let promotionId: Int
    @objc public let month: NSNumber?

    @objc public init(
        productId: String,
        price: Double,
        regularPrice: Double,
        currencyCode: String,
        promotionId: Int,
        month: NSNumber? = nil
    ) {
        self.productId = productId
        self.price = price
        self.regularPrice = regularPrice
        self.currencyCode = currencyCode
        self.promotionId = promotionId
        self.month = month
        super.init()
    }
}
