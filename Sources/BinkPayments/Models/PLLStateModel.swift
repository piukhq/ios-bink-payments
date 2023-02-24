//
//  PLLStateModel.swift
//  
//
//  Created by Sean Williams on 05/12/2022.
//

import Foundation


public struct LoyaltyCardPLLState {
    public var linked: [PaymentAccountResponseModel]
    public var unlinked: [PaymentAccountResponseModel]
    public var timeChecked: Date?
}


public struct PaymentAccountPLLState {
    public var linked: [LoyaltyCardModel]
    public var unlinked: [LoyaltyCardModel]
    public var timeChecked: Date?
}
