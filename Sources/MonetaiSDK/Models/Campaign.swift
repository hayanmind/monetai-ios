import Foundation

/// Model representing campaign information
public struct Campaign: Codable {
    public let id: Int
    public let createdAt: Date?
    public let organizationId: Int
    public let campaignName: String
    public let startedAt: Date?
    public let endedAt: Date?
    public let trafficRatio: Double
    public let allocationRatio: Double
    public let discountRatio: Double
    public let exposureTimeSec: Int
    public let modelAccuracy: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case organizationId = "organization_id"
        case campaignName = "campaign_name"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case trafficRatio = "traffic_ratio"
        case allocationRatio = "allocation_ratio"
        case discountRatio = "discount_ratio"
        case exposureTimeSec = "exposure_time_sec"
        case modelAccuracy = "model_accuracy"
    }
    
    public init(id: Int, createdAt: Date?, organizationId: Int, campaignName: String, startedAt: Date?, endedAt: Date?, trafficRatio: Double, allocationRatio: Double, discountRatio: Double, exposureTimeSec: Int, modelAccuracy: Double?) {
        self.id = id
        self.createdAt = createdAt
        self.organizationId = organizationId
        self.campaignName = campaignName
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.trafficRatio = trafficRatio
        self.allocationRatio = allocationRatio
        self.discountRatio = discountRatio
        self.exposureTimeSec = exposureTimeSec
        self.modelAccuracy = modelAccuracy
    }
} 