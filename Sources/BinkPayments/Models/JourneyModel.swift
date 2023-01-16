//
//  JourneyModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

struct JourneyModel: Codable {
    let type: Int?
    let description: String?
}

struct JourneyFieldsModel: Codable {
    let loyaltyPlanID: Int?
    let registerGhostCardFields: FieldsModel?
    let joinFields: FieldsModel?
    let addFields: FieldsModel?
    let authoriseFields: FieldsModel?

    enum CodingKeys: String, CodingKey {
        case loyaltyPlanID = "loyalty_plan_id"
        case registerGhostCardFields = "register_ghost_card_fields"
        case joinFields = "join_fields"
        case addFields = "add_fields"
        case authoriseFields = "authorise_fields"
    }
}
