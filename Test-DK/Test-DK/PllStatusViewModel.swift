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
    
    init() {
        linkedPaymentCardsForLoyaltyCard()
    }

    func linkedPaymentCardsForLoyaltyCard() {
        let loyaltyCardId = 254957
        if let loyaltyCard = paymentManager.loyaltyCard(from: loyaltyCardId) {
            loyaltyCardPllState = paymentManager.pllStatus(for: loyaltyCard) { [weak self] pllState in
                self?.loyaltyCardPllState = pllState
            }
        } else {
            print("No loylaty card found in wallet for id: \(loyaltyCardId)")
        }
    }
}
