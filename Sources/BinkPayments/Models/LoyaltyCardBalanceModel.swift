//
//  BalanceModel.swift
//  LocalHero
//
//  Created by Sean Williams on 04/04/2022.
//

import Foundation

// MARK: - Balance
public struct LoyaltyCardBalanceModel: Codable {
    public let apiId: Int?
    public let updatedAt: Int?
    public let currentDisplayValue: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case updatedAt = "updated_at"
        case currentDisplayValue = "current_display_value"
    }
}
