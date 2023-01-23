//
//  PllStatusView.swift
//  Test-DK
//
//  Created by Sean Williams on 18/01/2023.
//

import BinkPayments
import SwiftUI

struct PllStatusView: View {
    enum PllStatusType {
        case loyalty
        case payment
    }
    
    @State private var statusType: PllStatusType = .loyalty
    @ObservedObject var viewModel: PllStatusViewModel
    
    var body: some View {
        VStack {
            BinkButton(text: "Pll Status for Loyalty Card") {
                statusType = .loyalty
                viewModel.linkedPaymentCardsForLoyaltyCard()
            }
            
            BinkButton(text: "Pll Status for Payment Account") {
                statusType = .payment
                viewModel.linkedLoyaltyCardsForPaymentCard()
            }
            
            Spacer()

            if let _ = viewModel.loyaltyCardPllState {
                ScrollView {
                    Text("Last time checked:")
                        .font(.headline)
                    Text(viewModel.loyaltyCardPllState.timeChecked?.formatted(date: .complete, time: .standard) ?? "")
                    
                    Spacer()
                    
                    /// Linked Cards
                    Text("LINKED")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    PaymentCardsView(status: .linked, pllState: viewModel.loyaltyCardPllState)

                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.pink)
                    
                    /// Unlinked Cards
                    Text("UNLINKED")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    PaymentCardsView(status: .unlinked, pllState: viewModel.loyaltyCardPllState)
                }
            }
            
            if let _ = viewModel.paymentAccountPllState {
                ScrollView {
                    Text("Last time checked:")
                        .font(.headline)
                    Text(viewModel.paymentAccountPllState.timeChecked?.formatted(date: .complete, time: .standard) ?? "")
                    
                    Spacer()
                    
                    /// Linked Cards
                    Text("LINKED")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    LoyaltyCardsView(status: .linked, pllState: viewModel.paymentAccountPllState)

                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.pink)
                    
                    /// Unlinked Cards
                    Text("UNLINKED")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    LoyaltyCardsView(status: .unlinked, pllState: viewModel.paymentAccountPllState)
                }
            }
        }
        .padding()
    }
}

struct PllStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PllStatusView(viewModel: PllStatusViewModel(paymentManager: BinkPaymentsManager.shared))
    }
}
