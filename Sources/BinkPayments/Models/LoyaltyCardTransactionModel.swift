//
//  LoyaltyCardTransaction.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

struct LoyaltyCardTransactionModel: Codable {
    let apiId: Int?
    let timestamp: Double?
    let transactionDescription: String?
    let displayValue: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case timestamp
        case transactionDescription = "description"
        case displayValue = "display_value"
    }
}
