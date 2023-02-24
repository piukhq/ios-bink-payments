//
//  LoyaltyCardTransaction.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

/// Transaction associated with the Loyalty Card.
public struct LoyaltyCardTransactionModel: Codable {
    /// Resource Id
    public let apiId: String?
    
    /// Time and date of the transaction as supplied by the merchant.
    public let timestamp: Double?
    
    /// Human readable description of the transaction as supplied by the the merchant.
    public let transactionDescription: String?
    
    /// Value of transaction awarded as supplied by the merchant
    public let displayValue: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case timestamp
        case transactionDescription = "description"
        case displayValue = "display_value"
    }
}
