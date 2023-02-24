//
//  PLLStateModel.swift
//  
//
//  Created by Sean Williams on 05/12/2022.
//

import Foundation

/// Contains the links that a Loyalty Card has to Payment Accounts
public struct LoyaltyCardPLLState {
    /// Linked Payment Accounts
    public var linked: [PaymentAccountResponseModel]
    
    /// Unlinked Payment Accounts
    public var unlinked: [PaymentAccountResponseModel]
    
    /// Last time the links were checked
    public var timeChecked: Date?
}


public struct PaymentAccountPLLState {
    public var linked: [LoyaltyCardModel]
    public var unlinked: [LoyaltyCardModel]
    public var timeChecked: Date?
}
