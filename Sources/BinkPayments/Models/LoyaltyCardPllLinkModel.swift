//
//  LoyaltyCardPllLink.swift
//  
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

/// Details of the Payment Accounts associated with the Loyalty Card.
public struct LoyaltyCardPllLinkModel: Codable {
    /// Resource id
    public var apiId: Int?
    
    /// Unique identifier for the Payment Account.
    public let paymentAccountID: Int?
    
    /// The name of the payment processor.
    public let paymentScheme: String?
    
    /// PLL Status
    public let status: PLLStatus?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case paymentAccountID = "payment_account_id"
        case paymentScheme = "payment_scheme"
        case status
    }
}
