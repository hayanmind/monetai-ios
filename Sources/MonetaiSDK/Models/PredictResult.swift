import Foundation

/// Enum representing user prediction results
@objc public enum PredictResult: Int, Codable {
    case nonPurchaser = 0
    case purchaser = 1
    
    public var stringValue: String {
        switch self {
        case .nonPurchaser:
            return "non-purchaser"
        case .purchaser:
            return "purchaser"
        }
    }
    
    public init?(stringValue: String) {
        switch stringValue {
        case "non-purchaser":
            self = .nonPurchaser
        case "purchaser":
            self = .purchaser
        default:
            return nil
        }
    }
    
    // Custom decoding to handle string values from API
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            if let result = PredictResult(stringValue: stringValue) {
                self = result
            } else {
                // Handle null or invalid values by throwing an error
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid prediction value: \(stringValue)"
                )
            }
        } else if let intValue = try? container.decode(Int.self) {
            if let result = PredictResult(rawValue: intValue) {
                self = result
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid prediction int value: \(intValue)"
                )
            }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected string or int for prediction value"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
} 