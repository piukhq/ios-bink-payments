//
//  Wallet.swift
//  
//
//  Created by Sean Williams on 01/12/2022.
//

import Foundation
import FrameworkTest

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
                print("Wallet fetch complete")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func configurePLLState(for loyaltyCard: LoyaltyCardModel) -> LoyaltyCardPLLState {
        var pllState = LoyaltyCardPLLState(linked: [], unlinked: [], timeChecked: lastWalletUpdate)

        loyaltyCard.pllLinks?.forEach({ pllLink in
            if let paymentAccount = paymentAccounts?.first(where: { $0.apiId == pllLink.paymentAccountID }) {
                if pllLink.status?.state == "active" {
                    pllState.linked.append(paymentAccount)
                } else {
                    pllState.unlinked.append(paymentAccount)
                }
            }
        })
        
        return pllState
    }
    
    func configurePLLState(for paymentAccount: PaymentAccountResponseModel) -> PaymentAccountPLLState {
        var pllState = PaymentAccountPLLState(linked: [], unlinked: [], timeChecked: lastWalletUpdate)
        
        paymentAccount.pllLinks?.forEach({ pllLink in
            if let loyaltyCard = loyaltyCards?.first(where: { $0.apiId == pllLink.loyaltyCardID }) {
                if pllLink.status?.state == "active" {
                    pllState.linked.append(loyaltyCard)
                } else {
                    pllState.unlinked.append(loyaltyCard)
                }
            }
        })
        
        return pllState
    }
}
