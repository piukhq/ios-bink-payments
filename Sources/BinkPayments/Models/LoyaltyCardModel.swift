//
//  LoyaltyCardModel.swift
//  LocalHero
//
//  Created by Sean Williams on 01/04/2022.
//

import Foundation

/// Struct that contains information for a Loyalty Card
public struct LoyaltyCardModel: Codable {
    /// Resource Id
    public let apiId: Int?
    
    /// The unique resource identifier for the Loyalty Plan to which the Loyalty Card belongs.
    public let loyaltyPlanID: Int?
    
    /// The state of the Loyalty Card in a Wallet.
    public let status: StatusModel?
    
    /// Current loyalty balance for the Loyalty Card.
    public let balance: LoyaltyCardBalanceModel?
    
    /// List of transactions associated with the Loyalty Card.
    public let transactions: [LoyaltyCardTransactionModel]?
    
    /// List of vouchers associated with the Loyalty Card.
    public let vouchers: [VoucherModel]?
    
    /// Properties of the Loyalty Card.
    public let card: CardModel?
    
    /// List of the Payment Accounts with an active, pending or inactive PLL link to the Loyalty Card.
    public let pllLinks: [LoyaltyCardPllLinkModel]?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case loyaltyPlanID = "loyalty_plan_id"
        case status, balance, transactions, vouchers, card
        case pllLinks = "pll_links"
    }
}
