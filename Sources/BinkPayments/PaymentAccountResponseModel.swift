//
//  PaymentCardResponseModel.swift
//  
//
//  Created by Sean Williams on 24/11/2022.
//

import Foundation

/// Information related to a payment account
public struct PaymentAccountResponseModel: Codable {
    /// Resource Id
    public var apiId: Int?
    
    /// The current state of the Payment Account:
    /// active
    /// pending
    /// failed
    /// inactive
    /// retired
    public let status: String?
    
    /// Expiry month for this card.
    public let expiryMonth: String?
    
    ///Expiry year for this card.
    public let expiryYear: String?
    
    /// Card holder name as printed on card.
    public let nameOnCard: String?
    
    /// User defined nickname for this account.
    public let cardNickname: String?
    
    /// First six digits of the PAN
    public var firstSix: String?
    
    /// The last four digits of the PAN.
    public let lastFour: String?
    
    /// List of the Loyalty Cards with a PLL link to the Payment Account.
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
/// Represents a PLL link to a Payment Account
public struct PaymentAccountPllLink: Codable {
    /// Resource ID
    public let apiId: Int?
    
    /// Unique identifier for the Loyalty Card.
    public let loyaltyCardID: Int?
    
    /// The brand name of the Loyalty Plan.
    public let loyaltyPlan: String?
    
    /// The status of the PLL
    public let status: PLLStatus?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case loyaltyCardID = "loyalty_card_id"
        case loyaltyPlan = "loyalty_plan"
        case status
    }
}

/// Represents the PLL Status
public struct PLLStatus: Codable {
    /// The status of the PLL link:
    /// active
    /// pending
    /// inactive
    public let state: String?
    
    /// If the Loyalty Card or Payment Account is in a state other than active, there will be a human-readable identifier that is easy to code against.
    public let slug: String?
    
    /// If the Loyalty Card or Payment Account is in a state other than active, there will be text to describe the state of the PLL link.
    public let description: String?
}
