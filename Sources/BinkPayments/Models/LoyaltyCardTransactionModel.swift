//
//  LoyaltyCardTransaction.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

public struct LoyaltyCardTransactionModel: Codable {
    public let apiId: String?
    public let timestamp: Double?
    public let transactionDescription: String?
    public let displayValue: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case timestamp
        case transactionDescription = "description"
        case displayValue = "display_value"
    }
}
