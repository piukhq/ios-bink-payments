//
//  JourneyModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

public struct JourneyModel: Codable {
    public let type: Int?
    public let description: String?
}

public struct JourneyFieldsModel: Codable {
    public let loyaltyPlanID: Int?
    public let registerGhostCardFields: FieldsModel?
    public let joinFields: FieldsModel?
    public let addFields: FieldsModel?
    public let authoriseFields: FieldsModel?

    enum CodingKeys: String, CodingKey {
        case loyaltyPlanID = "loyalty_plan_id"
        case registerGhostCardFields = "register_ghost_card_fields"
        case joinFields = "join_fields"
        case addFields = "add_fields"
        case authoriseFields = "authorise_fields"
    }
}
