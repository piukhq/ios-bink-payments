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

struct LoyaltyCardUpdateTrustedRequestModel: Codable {
    let account: Account
}

struct Account: Codable {
    let addFields: AddFields?
    let authoriseFields: AuthoriseFields?
    let merchantFields: MerchantFields

    enum CodingKeys: String, CodingKey {
        case addFields = "add_fields"
        case authoriseFields = "authorise_fields"
        case merchantFields = "merchant_fields"
    }
}

struct AuthoriseFields: Codable {
    let credentials: [Credential]
}

struct AddFields: Codable {
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

public enum LoyaltyIdType {
    case email
    case cardNumber(String)
    
    var slug: String {
        switch self {
        case .email:
            return "email"
        case .cardNumber:
            return "card_number"
        }
    }
    
    var value: String {
        switch self {
        case .email:
            return BinkPaymentsManager.shared.email
        case .cardNumber( let cardNumber):
            return cardNumber
        }
    }
}
