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
    
    @Published var loyaltyCardPllState: LoyaltyCardPLLState?
    @Published var loyaltyCardExists = true
    
    init() {
        linkedPaymentCardsForLoyaltyCard()
    }

    func linkedPaymentCardsForLoyaltyCard() {
        if let loyaltyCard = paymentManager.loyaltyCard() {
            loyaltyCardPllState = paymentManager.pllStatus(for: loyaltyCard) { [weak self] pllState in
                self?.loyaltyCardPllState = pllState
            }
        } else {
            print("No loyalty card found in wallet")
            loyaltyCardExists = false
        }
    }
}
