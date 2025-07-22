import Foundation

/// Enum representing A/B test groups
public enum ABTestGroup: String, Codable {
    case baseline = "baseline"
    case monetai = "monetai"
    case unknown = "unknown"
} 