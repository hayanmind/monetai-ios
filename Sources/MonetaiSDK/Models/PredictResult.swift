import Foundation

/// Enum representing user prediction results
public enum PredictResult: String, Codable {
    case nonPurchaser = "non-purchaser"
    case purchaser = "purchaser"
} 