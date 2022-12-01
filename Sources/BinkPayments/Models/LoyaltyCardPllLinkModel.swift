//
//  LoyaltyCardPllLink.swift
//  
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

struct LoyaltyCardPllLinkModel: Codable {
    var apiId: Int?
    let paymentAccountID: Int?
    let paymentScheme, status: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case paymentAccountID = "payment_account_id"
        case paymentScheme = "payment_scheme"
        case status
    }
}
