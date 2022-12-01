//
//  LoyaltyCardModel.swift
//  LocalHero
//
//  Created by Sean Williams on 01/04/2022.
//

import Foundation

struct LoyaltyCardModel: Codable {
    let apiId: Int?
    let loyaltyPlanID: Int?
    let status: StatusModel?
    let balance: LoyaltyCardBalanceModel?
    let transactions: [LoyaltyCardTransactionModel]?
    let vouchers: [VoucherModel]?
    let card: CardModel?
    let pllLinks: [LoyaltyCardPllLinkModel]?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case loyaltyPlanID = "loyalty_plan_id"
        case status, balance, transactions, vouchers, card
        case pllLinks = "pll_links"
    }
}
