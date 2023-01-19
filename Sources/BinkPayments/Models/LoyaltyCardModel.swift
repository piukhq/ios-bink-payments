//
//  LoyaltyCardModel.swift
//  LocalHero
//
//  Created by Sean Williams on 01/04/2022.
//

import Foundation

public struct LoyaltyCardModel: Codable {
    public let apiId: Int?
    public let loyaltyPlanID: Int?
    public let status: StatusModel?
    public let balance: LoyaltyCardBalanceModel?
    public let transactions: [LoyaltyCardTransactionModel]?
    public let vouchers: [VoucherModel]?
    public let card: CardModel?
    public let pllLinks: [LoyaltyCardPllLinkModel]?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case loyaltyPlanID = "loyalty_plan_id"
        case status, balance, transactions, vouchers, card
        case pllLinks = "pll_links"
    }
}
