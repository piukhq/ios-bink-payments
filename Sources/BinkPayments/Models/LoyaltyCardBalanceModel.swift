//
//  BalanceModel.swift
//  LocalHero
//
//  Created by Sean Williams on 04/04/2022.
//

import Foundation

// MARK: - Balance
struct LoyaltyCardBalanceModel: Codable {
    let apiId: Int?
    let updatedAt: Int?
    let currentDisplayValue: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case updatedAt = "updated_at"
        case currentDisplayValue = "current_display_value"
    }
}
