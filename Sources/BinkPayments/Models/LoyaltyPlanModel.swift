//
//  LoyaltyPlans.swift
//  Local Hero
//
//  Created by Sean Williams on 10/12/2021.
//

import CoreData
import Foundation

public struct LoyaltyPlanModel: Codable {
    public let apiId: Int?
    public let planPopularity: Int?
    public let planFeatures: LoyaltyPlanFeaturesModel?
    public let images: [ImageModel]?
    public let planDetails: LoyaltyPlanDetailsModel?
    public let journeyFields: JourneyFieldsModel?
    public let content: [ContentModel]?

    enum CodingKeys: String, CodingKey {
        case apiId = "loyalty_plan_id"
        case planPopularity = "plan_popularity"
        case planFeatures = "plan_features"
        case images, content
        case planDetails = "plan_details"
        case journeyFields = "journey_fields"
    }
}
