//
//  WalletModel.swift
//  LocalHero
//
//  Created by Sean Williams on 14/03/2022.
//

import Foundation

struct WalletModel: Codable {
    let apiId: Int?
    let joins: [JoinModel]?
    let loyaltyCards: [LoyaltyCardModel]?
    let paymentAccounts: [PaymentAccountResponseModel]?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case joins
        case loyaltyCards = "loyalty_cards"
        case paymentAccounts = "payment_accounts"
    }
}
