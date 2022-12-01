//
//  PaymentCardResponseModel.swift
//  
//
//  Created by Sean Williams on 24/11/2022.
//

import Foundation

struct PaymentAccountResponseModel: Codable {
    var apiId: Int?
    let status: String?
    let expiryMonth: String?
    let expiryYear: String?
    let nameOnCard: String?
    let cardNickname: String?
    var firstSix: String?
    let lastFour: String?
    let pllLinks: [PaymentAccountPllLink]?

    enum CodingKeys: String, CodingKey {
        case expiryMonth = "expiry_month"
        case expiryYear = "expiry_year"
        case nameOnCard = "name_on_card"
        case cardNickname = "card_nickname"
        case firstSix = "first_six_digits"
        case lastFour = "last_four_digits"
        case pllLinks = "pll_links"
        case apiId = "id"
        case status
    }
}

// MARK: - PaymentAccountPllLink
struct PaymentAccountPllLink: Codable {
    let apiId: Int?
    let loyaltyCardID: Int?
    let loyaltyPlan: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case loyaltyCardID = "loyalty_card_id"
        case loyaltyPlan = "loyalty_plan"
        case status
    }
}
