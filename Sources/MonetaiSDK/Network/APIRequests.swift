import Foundation
import Alamofire

/// Struct containing API request methods
struct APIRequests {

    // MARK: - Initialize
    struct InitializeRequest: Codable {
        let sdkKey: String
        let platform: String
        let version: String
    }

    struct InitializeResponse: Codable {
        let organizationId: Int
        let platform: String
        let version: String
        let serverTimestamp: Int64

        enum CodingKeys: String, CodingKey {
            case organizationId = "organization_id"
            case platform
            case version
            case serverTimestamp = "server_timestamp"
        }
    }

    static func initialize(sdkKey: String) async throws -> InitializeResponse {
        let initRequest = InitializeRequest(
            sdkKey: sdkKey,
            platform: "ios",
            version: SDKVersion.getVersion()
        )

        let initResponse: InitializeResponse = try await APIClient.shared.request(
            endpoint: "/sdk-integrations",
            method: .post,
            parameters: initRequest.dictionary,
            encoding: JSONEncoding.default
        )

        return initResponse
    }

    // MARK: - Events
    struct EventRequest {
        let sdkKey: String
        let userId: String
        let eventName: String
        let createdAt: Date?
        let params: [String: Any]?
        let platform: String

        var dictionary: [String: Any] {
            var dict: [String: Any] = [
                "sdkKey": sdkKey,
                "userId": userId,
                "eventName": eventName,
                "platform": platform
            ]

            if let createdAt = createdAt {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                dict["createdAt"] = formatter.string(from: createdAt)
            }

            if let params = params {
                do {
                    _ = try JSONSerialization.data(withJSONObject: params)
                    dict["params"] = params
                } catch {
                    // Exclude parameters that cannot be serialized
                }
            }
            return dict
        }
    }

    static func createEvent(sdkKey: String, userId: String, eventName: String, params: [String: Any]? = nil, createdAt: Date? = nil) async throws {
        let request = EventRequest(
            sdkKey: sdkKey,
            userId: userId,
            eventName: eventName,
            createdAt: createdAt,
            params: params,
            platform: "ios"
        )

        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/events",
            method: .post,
            parameters: request.dictionary,
            encoding: JSONEncoding.default
        )
    }

    // MARK: - View Product Item Event
    static func createViewProductItemEvent(sdkKey: String, userId: String, params: ViewProductItemParams, createdAt: Date? = nil) async throws {
        var dict: [String: Any] = [
            "sdkKey": sdkKey,
            "userId": userId,
            "productId": params.productId,
            "price": params.price,
            "regularPrice": params.regularPrice,
            "currencyCode": params.currencyCode,
            "placement": params.placement,
            "platform": "ios"
        ]

        if let promotionId = params.promotionId {
            dict["promotionId"] = promotionId.intValue
        }

        if let month = params.month {
            dict["month"] = month.intValue
        }

        if let createdAt = createdAt {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            dict["createdAt"] = formatter.string(from: createdAt)
        }

        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/events/view-product-item",
            method: .post,
            parameters: dict,
            encoding: JSONEncoding.default
        )
    }

    // MARK: - Get Offer
    static func getOffer(sdkKey: String, userId: String, promotionId: Int) async throws -> Offer? {
        let parameters: [String: Any] = [
            "sdkKey": sdkKey,
            "userId": userId,
            "promotionId": promotionId,
            "platform": "ios"
        ]

        let offer: Offer? = try await APIClient.shared.request(
            endpoint: "/offers/get-offer",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        return offer
    }

    // MARK: - Transaction ID Mapping
    struct TransactionMappingRequest: Codable {
        let transactionId: String
        let bundleId: String
        let userId: String
        let sdkKey: String
    }

    static func mapTransactionToUser(transactionId: String, bundleId: String, sdkKey: String, userId: String) async throws {
        let request = TransactionMappingRequest(
            transactionId: transactionId,
            bundleId: bundleId,
            userId: userId,
            sdkKey: sdkKey
        )

        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/transaction-id-to-user-id/ios",
            method: .post,
            parameters: request.dictionary,
            encoding: JSONEncoding.default
        )
    }

    // MARK: - Receipt Validation
    struct ReceiptValidationRequest: Codable {
        let receiptData: String
        let bundleId: String
        let userId: String
        let sdkKey: String
    }

    static func validateReceipt(receiptData: String, bundleId: String, sdkKey: String, userId: String) async throws {
        let request = ReceiptValidationRequest(
            receiptData: receiptData,
            bundleId: bundleId,
            userId: userId,
            sdkKey: sdkKey
        )

        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/transaction-id-to-user-id/ios/receipt",
            method: .post,
            parameters: request.dictionary,
            encoding: JSONEncoding.default
        )
    }
}

// MARK: - Helper Extensions
extension Encodable {
    var dictionary: [String: Any] {
        let encoder = JSONEncoder()

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            let dateString = formatter.string(from: date)
            var container = encoder.singleValueContainer()
            try container.encode(dateString)
        }

        guard let data = try? encoder.encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] } ?? [:]
    }
}

struct EmptyResponse: Codable {}
