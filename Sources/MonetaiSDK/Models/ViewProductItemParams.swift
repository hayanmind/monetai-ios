import Foundation

/// Parameters for logging a product view event
@objc public class ViewProductItemParams: NSObject {
    @objc public let placement: String
    @objc public let productId: String
    @objc public let price: Double
    @objc public let regularPrice: Double
    @objc public let currencyCode: String
    @objc public let month: NSNumber?

    @objc public init(
        placement: String,
        productId: String,
        price: Double,
        regularPrice: Double,
        currencyCode: String,
        month: NSNumber? = nil
    ) {
        self.placement = placement
        self.productId = productId
        self.price = price
        self.regularPrice = regularPrice
        self.currencyCode = currencyCode
        self.month = month
        super.init()
    }
}
