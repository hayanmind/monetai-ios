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
        
        enum CodingKeys: String, CodingKey {
            case organizationId = "organization_id"
            case platform
            case version
        }
    }
    
    static func initialize(sdkKey: String, userId: String) async throws -> (InitializeResponse, ABTestResponse) {
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
        
        let abTestResponse: ABTestResponse = try await APIClient.shared.request(
            endpoint: "/ab-test",
            method: .post,
            parameters: [
                "sdkKey": sdkKey,
                "userId": userId,
                "platform": "ios"
            ],
            encoding: JSONEncoding.default
        )
        
        return (initResponse, abTestResponse)
    }
    
    // MARK: - AB Test
    struct ABTestResponse: Codable {
        let group: ABTestGroup?
        let campaign: Campaign?
    }
    
    // MARK: - Events
    struct EventRequest {
        let sdkKey: String
        let userId: String
        let eventName: String
        let createdAt: Date
        let params: [String: Any]?
        let platform: String
        
        var dictionary: [String: Any] {
            // Convert Date to ISO8601 string
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            var dict: [String: Any] = [
                "sdkKey": sdkKey,
                "userId": userId,
                "eventName": eventName,
                "createdAt": formatter.string(from: createdAt),
                "platform": platform
            ]
            
            if let params = params {
                // Check if params can be JSON serialized
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
    
    static func createEvent(sdkKey: String, userId: String, eventName: String, params: [String: Any]? = nil, createdAt: Date = Date()) async throws {
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
    
    // MARK: - Predict
    struct PredictRequest: Codable {
        let sdkKey: String
        let userId: String
    }
    
    struct PredictResponse: Codable {
        let prediction: PredictResult?
        let testGroup: ABTestGroup?
    }
    
    static func predict(sdkKey: String, userId: String) async throws -> PredictResponse {
        let request = PredictRequest(sdkKey: sdkKey, userId: userId)
        
        return try await APIClient.shared.request(
            endpoint: "/predict",
            method: .post,
            parameters: request.dictionary,
            encoding: JSONEncoding.default
        )
    }
    
    // MARK: - App User Discount
    struct CreateDiscountRequest: Codable {
        let sdkKey: String
        let appUserId: String
        let startedAt: Date
        let endedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case sdkKey
            case appUserId
            case startedAt
            case endedAt
        }
    }
    
    struct CreateDiscountResponse: Codable {
        let discount: AppUserDiscount
    }
    
    static func createAppUserDiscount(sdkKey: String, userId: String, startedAt: Date, endedAt: Date) async throws -> AppUserDiscount {
        let request = CreateDiscountRequest(
            sdkKey: sdkKey,
            appUserId: userId,
            startedAt: startedAt,
            endedAt: endedAt
        )
        
        let response: CreateDiscountResponse = try await APIClient.shared.request(
            endpoint: "/app-user-discounts",
            method: .post,
            parameters: request.dictionary,
            encoding: JSONEncoding.default
        )
        
        return response.discount
    }
    
    struct GetDiscountResponse: Codable {
        let discount: AppUserDiscount?
    }
    
    static func getAppUserDiscount(sdkKey: String, userId: String) async throws -> AppUserDiscount? {
        let response: GetDiscountResponse = try await APIClient.shared.request(
            endpoint: "/app-user-discounts/latest",
            method: .get,
            parameters: [
                "sdkKey": sdkKey,
                "appUserId": userId
            ]
        )
        
        return response.discount
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
        
        // Encode to ISO 8601 date format
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