//
//  LoyaltyPlans.swift
//  Local Hero
//
//  Created by Sean Williams on 10/12/2021.
//

import CoreData
import Foundation

/// Struct that contains information for the specified Loyalty Plan.
public struct LoyaltyPlanModel: Codable {
    /// Resource id
    public let apiId: Int?
    
    /// Numeric rank for this plan's popularity.
    public let planPopularity: Int?
    
    /// List of the Loyalty Plan properties.
    public let planFeatures: LoyaltyPlanFeaturesModel?
    
    /// List of all images associated with the resource.
    public let images: [ImageModel]?
    
    /// Loyalty Plan details
    public let planDetails: LoyaltyPlanDetailsModel?
    
    /// User information required to support Loyalty journeys
    public let journeyFields: JourneyFieldsModel?
    
    /// Key value pairs that can be used to support UI elements.
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
