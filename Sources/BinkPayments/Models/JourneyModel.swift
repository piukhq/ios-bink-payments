//
//  JourneyModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

/// Struct that represents a journey that a plan supports.
public struct JourneyModel: Codable {
    /// Resource identifier.
    public let type: Int?
    
    /// ADD
    /// AUTHORISE
    /// REGISTER
    /// JOIN
    public let description: String?
}

/// User information required to support Loyalty journeys.
public struct JourneyFieldsModel: Codable {
    /// Reource Id
    public let loyaltyPlanID: Int?
    
    /// The fields that need to be presented to the user in order to Register a Ghostcard.
    public let registerGhostCardFields: FieldsModel?
    
    /// The fields that need to be presented to the user in order to become a new member of the Loyalty Plan.
    public let joinFields: FieldsModel?
    
    /// The fields that need to be presented to the user in order to Add an existing Loyalty Card as Store type to the user's wallet.
    public let addFields: FieldsModel?
    
    /// The fields that need to be presented to the user in order to Authorise a Store type Loyalty Card already in a user's wallet.
    public let authoriseFields: FieldsModel?

    enum CodingKeys: String, CodingKey {
        case loyaltyPlanID = "loyalty_plan_id"
        case registerGhostCardFields = "register_ghost_card_fields"
        case joinFields = "join_fields"
        case addFields = "add_fields"
        case authoriseFields = "authorise_fields"
    }
}
