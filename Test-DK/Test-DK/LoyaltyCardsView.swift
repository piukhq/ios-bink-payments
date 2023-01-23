//
//  LoyaltyCardsView.swift
//  Test-DK
//
//  Created by Sean Williams on 23/01/2023.
//

import BinkPayments
import SwiftUI

struct LoyaltyCardsView: View {
    enum LinkedStatus {
        case linked
        case unlinked
    }
    
    var status: LinkedStatus
    var pllState: PaymentAccountPLLState
    
    var loyaltyCardsForLinkedStatus: [LoyaltyCardModel] {
        switch status {
        case .linked:
            return pllState.linked
        case .unlinked:
            return pllState.unlinked
        }
    }
    
    var body: some View {
        ForEach(loyaltyCardsForLinkedStatus, id: \.apiId) { loyaltyCard in
            HStack {
                VStack(alignment: .leading) {
                    Text("ID: \(String(loyaltyCard.apiId ?? 0))")
                        .fontWeight(.medium)
                        .foregroundColor(status == .linked ? .green : .red)
                    Text("Loyalty Plan ID: \(loyaltyCard.loyaltyPlanID ?? 0)")
                        .fontWeight(.light)
                }
                Spacer()
                Text("Card number: \(loyaltyCard.card?.cardNumber ?? loyaltyCard.card?.barcode ?? "")")
            }
            .padding(.bottom, 10)
        }
    }
}

struct PaymentCardsView: View {
    enum LinkedStatus {
        case linked
        case unlinked
    }
    
    var status: LinkedStatus
    var pllState: LoyaltyCardPLLState
    
    var paymentCardsForLinkedStatus: [PaymentAccountResponseModel] {
        switch status {
        case .linked:
            return pllState.linked
        case .unlinked:
            return pllState.unlinked
        }
    }
    
    var body: some View {
        ForEach(paymentCardsForLinkedStatus, id: \.apiId) { paymentAccount in
            HStack {
                VStack(alignment: .leading) {
                    Text("ID: \(String(paymentAccount.apiId ?? 0))")
                        .fontWeight(.medium)
                        .foregroundColor(status == .linked ? .green : .red)
                    Text(paymentAccount.nameOnCard ?? "")
                        .fontWeight(.light)
                }
                Spacer()
                Text("Card number ending: \(paymentAccount.lastFour ?? "")")
            }
            .padding(.bottom, 10)
        }
    }
}
