//
//  PLLStateModel.swift
//  
//
//  Created by Sean Williams on 05/12/2022.
//

import Foundation


public struct LoyaltyCardPLLState {
    var linked: [PaymentAccountResponseModel]
    var unlinked: [PaymentAccountResponseModel]
    var timeChecked: Date?
}


public struct PaymentAccountPLLState {
    var linked: [LoyaltyCardModel]
    var unlinked: [LoyaltyCardModel]
    var timeChecked: Date?
}
