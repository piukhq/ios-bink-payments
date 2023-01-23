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
                Text("Last time checked:")
                    .font(.headline)
                Text(viewModel.loyaltyCardPllState.timeChecked?.formatted(date: .complete, time: .standard) ?? "")
                
                Spacer()
                
                /// Linked Cards
                Text("LINKED")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                PaymentAccountsView(status: .linked, pllState: viewModel.loyaltyCardPllState)

                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.pink)
                
                /// Unlinked Cards
                Text("UNLINKED")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                PaymentAccountsView(status: .unlinked, pllState: viewModel.loyaltyCardPllState)
            }
            
//            if let _ = viewModel.paymentAccountPllState {
//                ScrollView {
//                    Text("Last time checked:")
//                        .font(.headline)
//                    Text(viewModel.paymentAccountPllState.timeChecked?.formatted(date: .complete, time: .standard) ?? "")
//                    
//                    Spacer()
//                    
//                    /// Linked Cards
//                    Text("LINKED")
//                        .font(.subheadline)
//                        .fontWeight(.bold)
//                        .foregroundColor(.green)
//                    
//                    LoyaltyCardsView(status: .linked, pllState: viewModel.paymentAccountPllState)
//
//                    
//                    Rectangle()
//                        .frame(height: 2)
//                        .foregroundColor(.pink)
//                    
//                    /// Unlinked Cards
//                    Text("UNLINKED")
//                        .font(.subheadline)
//                        .fontWeight(.bold)
//                        .foregroundColor(.red)
//                    
//                    LoyaltyCardsView(status: .unlinked, pllState: viewModel.paymentAccountPllState)
//                }
//            }
        }
        .padding()
    }
}

struct PllStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PllStatusView()
    }
}
