import Foundation

/// Model representing app user discount information
@objc public class AppUserDiscount: NSObject, Codable {
    @objc public let startedAt: Date
    @objc public let endedAt: Date
    @objc public let appUserId: String
    @objc public let sdkKey: String
    
    enum CodingKeys: String, CodingKey {
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case appUserId = "app_user_id"
        case sdkKey = "sdk_key"
    }
    
    @objc public init(startedAt: Date, endedAt: Date, appUserId: String, sdkKey: String) {
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.appUserId = appUserId
        self.sdkKey = sdkKey
        super.init()
    }
    
    // Custom description for better logging
    public override var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return "AppUserDiscount(startedAt: \(dateFormatter.string(from: startedAt)), endedAt: \(dateFormatter.string(from: endedAt)), appUserId: \"\(appUserId)\", sdkKey: \"\(sdkKey)\")"
    }
} 