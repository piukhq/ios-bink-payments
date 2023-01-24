//
//  LoyaltyCardTrustedModel.swift
//  
//
//  Created by Ricardo Silva on 24/01/2023.
//

import Foundation

struct LoyaltyCardAddTrustedRequestModel: Codable {
    let loyaltyPlanID: Int
    let account: Account

    enum CodingKeys: String, CodingKey {
        case loyaltyPlanID = "loyalty_plan_id"
        case account
    }
}

struct Account: Codable {
    let authoriseFields: AuthoriseFields
    let merchantFields: MerchantFields

    enum CodingKeys: String, CodingKey {
        case authoriseFields = "authorise_fields"
        case merchantFields = "merchant_fields"
    }
}

struct AuthoriseFields: Codable {
    let credentials: [Credential]
}

struct Credential: Codable {
    let credentialSlug, value: String

    enum CodingKeys: String, CodingKey {
        case credentialSlug = "credential_slug"
        case value
    }
}

struct MerchantFields: Codable {
    let accountID: String

    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
    }
}

struct LoyaltyCardTrustedResponseModel: Codable {
    let id: Int
}
