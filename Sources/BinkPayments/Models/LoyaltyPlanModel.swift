//
//  LoyaltyPlans.swift
//  Local Hero
//
//  Created by Sean Williams on 10/12/2021.
//

import CoreData
import Foundation

struct LoyaltyPlanModel: Codable {
    let apiId: Int?
    let planPopularity: Int?
    let planFeatures: LoyaltyPlanFeaturesModel?
    let images: [ImageModel]?
    let planDetails: LoyaltyPlanDetailsModel?
    let journeyFields: JourneyFieldsModel?
    let content: [ContentModel]?

    enum CodingKeys: String, CodingKey {
        case apiId = "loyalty_plan_id"
        case planPopularity = "plan_popularity"
        case planFeatures = "plan_features"
        case images, content
        case planDetails = "plan_details"
        case journeyFields = "journey_fields"
    }
}
