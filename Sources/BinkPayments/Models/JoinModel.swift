//
//  JoinModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/03/2022.
//

import Foundation


// MARK: - Join
struct JoinModel: Codable {
    let loyaltyCardID, loyaltyPlanID: Int?
    let status: StatusModel?

    enum CodingKeys: String, CodingKey {
        case loyaltyCardID = "loyalty_card_id"
        case loyaltyPlanID = "loyalty_plan_id"
        case status
    }
}


