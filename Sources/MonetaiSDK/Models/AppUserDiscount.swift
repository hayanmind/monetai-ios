import Foundation

/// Model representing app user discount information
public struct AppUserDiscount: Codable {
    public let startedAt: Date
    public let endedAt: Date
    public let appUserId: String
    public let sdkKey: String
    
    enum CodingKeys: String, CodingKey {
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case appUserId = "app_user_id"
        case sdkKey = "sdk_key"
    }
    
    public init(startedAt: Date, endedAt: Date, appUserId: String, sdkKey: String) {
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.appUserId = appUserId
        self.sdkKey = sdkKey
    }
} 