//
//  JoinModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/03/2022.
//

import Foundation


// MARK: - Join

/// Loyalty Card associated with a loyalty plan and respective status
public struct JoinModel: Codable {
    public let loyaltyCardID, loyaltyPlanID: Int?
    public let status: StatusModel?

    enum CodingKeys: String, CodingKey {
        case loyaltyCardID = "loyalty_card_id"
        case loyaltyPlanID = "loyalty_plan_id"
        case status
    }
}


