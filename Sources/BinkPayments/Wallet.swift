//
//  Wallet.swift
//  
//
//  Created by Sean Williams on 01/12/2022.
//

import Foundation

class Wallet: WalletServiceProtocol {
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

        for paymentAccount in paymentAccounts ?? [] {
            if let loyaltyCardPllLink = loyaltyCard.pllLinks?.first(where: { $0.paymentAccountID == paymentAccount.apiId }) {
                if loyaltyCardPllLink.status?.state == "active" {
                    pllState.linked.append(paymentAccount)
                } else {
                    pllState.unlinked.append(paymentAccount)
                }
            } else {
                pllState.unlinked.append(paymentAccount)
            }
        }
        return pllState
    }
    
//    func configurePLLState(for paymentAccount: PaymentAccountResponseModel) -> PaymentAccountPLLState {
//        var pllState = PaymentAccountPLLState(linked: [], unlinked: [], timeChecked: lastWalletUpdate)
//        
//        if let loyaltyCard = loyaltyCard {
//            if let paymentAccountPllLink = paymentAccount.pllLinks?.first(where: { $0.loyaltyCardID == loyaltyCard.apiId }) {
//                if paymentAccountPllLink.status?.state == "active" {
//                    pllState.linked.append(loyaltyCard)
//                } else {
//                    pllState.unlinked.append(loyaltyCard)
//                }
//            } else {
//                pllState.unlinked.append(loyaltyCard)
//            }
//        }        
//        return pllState
//    }
}
