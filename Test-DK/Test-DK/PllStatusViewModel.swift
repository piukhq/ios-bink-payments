//
//  PllStatusViewModel.swift
//  Test-DK
//
//  Created by Sean Williams on 23/01/2023.
//

import BinkPayments
import Foundation


class PllStatusViewModel: ObservableObject {
    private let paymentManager = BinkPaymentsManager.shared
    
    @Published var loyaltyCardPllState: LoyaltyCardPLLState!
    @Published var paymentAccountPllState: PaymentAccountPLLState!

    func linkedPaymentCardsForLoyaltyCard() {
        let loyaltyCardId = 254957
        paymentAccountPllState = nil
        if let loyaltyCard = paymentManager.loyaltyCard(from: loyaltyCardId) {
            loyaltyCardPllState = paymentManager.pllStatus(for: loyaltyCard) { [weak self] pllState in
                self?.loyaltyCardPllState = pllState
            }
        } else {
            print("No loylaty card found in wallet for id: \(loyaltyCardId)")
        }
    }
    
    func linkedLoyaltyCardsForPaymentCard() {
        let paymentAccountId = 157839
        loyaltyCardPllState = nil
        if let paymentAccount = paymentManager.paymentAccount(from: paymentAccountId) {
            paymentAccountPllState = paymentManager.pllStatus(for: paymentAccount, refreshedLinkedState: { [weak self] pllState in
                self?.paymentAccountPllState = pllState
            })
        } else {
            print("No payment account card found in wallet for id: \(paymentAccountId)")
        }
    }
}
