//
//  PaymentCardResponseModel.swift
//  
//
//  Created by Sean Williams on 24/11/2022.
//

import Foundation

public struct PaymentAccountResponseModel: Codable {
    public var apiId: Int?
    public let status: String?
    public let expiryMonth: String?
    public let expiryYear: String?
    public let nameOnCard: String?
    public let cardNickname: String?
    public var firstSix: String?
    public let lastFour: String?
    public let pllLinks: [PaymentAccountPllLink]?

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
public struct PaymentAccountPllLink: Codable {
    public let apiId: Int?
    public let loyaltyCardID: Int?
    public let loyaltyPlan: String?
    public let status: PLLStatus?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case loyaltyCardID = "loyalty_card_id"
        case loyaltyPlan = "loyalty_plan"
        case status
    }
}

public struct PLLStatus: Codable {
    public let state: String?
    public let slug: String?
    public let description: String?
}
