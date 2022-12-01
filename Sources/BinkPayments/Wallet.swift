//
//  Wallet.swift
//  
//
//  Created by Sean Williams on 01/12/2022.
//

import Foundation

class Wallet: WalletService {
    private(set) var paymentAccounts: [PaymentAccountResponseModel]?
    private(set) var loyaltyCards: [LoyaltyCardModel]?
    
    var lastWalletUpdate: Date?
    
    func launch() {
        getWalletFromAPI { result in
            switch result {
            case .success(let response):
                self.paymentAccounts = response.paymentAccounts
                self.loyaltyCards = response.loyaltyCards
                self.lastWalletUpdate = Date()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
