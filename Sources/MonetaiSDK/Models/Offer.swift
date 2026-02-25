import Foundation

/// Model representing a product within an offer
@objc public class OfferProduct: NSObject, Codable {
    @objc public let name: String
    @objc public let sku: String
    @objc public let discountRate: Double
    @objc public let isManual: Bool

    public init(name: String, sku: String, discountRate: Double, isManual: Bool) {
        self.name = name
        self.sku = sku
        self.discountRate = discountRate
        self.isManual = isManual
        super.init()
    }
}

/// Model representing a dynamic pricing offer
@objc public class Offer: NSObject, Codable {
    @objc public let agentId: Int
    @objc public let agentName: String
    @objc public let products: [OfferProduct]

    public init(agentId: Int, agentName: String, products: [OfferProduct]) {
        self.agentId = agentId
        self.agentName = agentName
        self.products = products
        super.init()
    }
}
