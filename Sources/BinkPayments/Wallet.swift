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
    
    func fetch(completion: (() -> Void)? = nil) {
        getWalletFromAPI { result in
            switch result {
            case .success(let response):
                self.paymentAccounts = response.paymentAccounts
                self.loyaltyCards = response.loyaltyCards
                self.lastWalletUpdate = Date()
                completion?()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func configurePLLState(for loyaltyCard: LoyaltyCardModel) -> LoyaltyCardPLLState {
        var pllState = LoyaltyCardPLLState(linked: [], unlinked: [], timeChecked: lastWalletUpdate)

        loyaltyCard.pllLinks?.forEach({ pllLink in
            if let paymentAccount = paymentAccounts?.first(where: { $0.apiId == pllLink.paymentAccountID }) {
                if pllLink.status == "active" {
                    pllState.linked.append(paymentAccount)
                } else {
                    pllState.unlinked.append(paymentAccount)
                }
            }
        })
        
        return pllState
    }
}
