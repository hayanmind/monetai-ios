import Foundation

/// Enum representing A/B test groups
@objc public enum ABTestGroup: Int, Codable {
    case baseline = 0
    case monetai = 1
    case unknown = 2
    
    public var stringValue: String {
        switch self {
        case .baseline:
            return "baseline"
        case .monetai:
            return "monetai"
        case .unknown:
            return "unknown"
        }
    }
    
    public init?(stringValue: String) {
        switch stringValue {
        case "baseline":
            self = .baseline
        case "monetai":
            self = .monetai
        case "unknown":
            self = .unknown
        default:
            return nil
        }
    }
    
    // Custom decoding to handle string values from API
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            if let group = ABTestGroup(stringValue: stringValue) {
                self = group
            } else {
                self = .unknown
            }
        } else if let intValue = try? container.decode(Int.self) {
            if let group = ABTestGroup(rawValue: intValue) {
                self = group
            } else {
                self = .unknown
            }
        } else {
            self = .unknown
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
} 