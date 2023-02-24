//
//  PllStatusView.swift
//  Test-DK
//
//  Created by Sean Williams on 18/01/2023.
//

import BinkPayments
import SwiftUI

struct PllStatusView: View {
    @ObservedObject var viewModel = PllStatusViewModel()
    
    var body: some View {
        VStack {
            BinkButton(text: "Refresh") {
                viewModel.linkedPaymentCardsForLoyaltyCard()
            }
            
            Spacer()
            
            ScrollView {
                if let pllState = viewModel.loyaltyCardPllState {

                    Text("Last time checked:")
                        .font(.headline)
                    Text(pllState.timeChecked?.formatted(date: .complete, time: .standard) ?? "")
                    
                    Spacer()
                    
                    /// Linked Cards
                    Text("LINKED")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    PaymentAccountsView(status: .linked, pllState: pllState)
                    
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.pink)
                    
                    /// Unlinked Cards
                    Text("UNLINKED")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    PaymentAccountsView(status: .unlinked, pllState: pllState)
                } else {
                    Text("Error retrieving PLL data")
                    if !viewModel.loyaltyCardExists {
                        Text("No loyalty card found in wallet")
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            viewModel.linkedPaymentCardsForLoyaltyCard()
        }
    }
}

struct PllStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PllStatusView()
    }
}
