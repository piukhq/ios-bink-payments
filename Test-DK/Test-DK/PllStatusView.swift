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
            BinkButton(text: "Loyalty Card") {
                statusType = .loyalty
                viewModel.linkedPaymentCardsForLoyaltyCard()
            }
            
            BinkButton(text: "Payment Account") {
                statusType = .payment
            }
            
            Spacer()
            VStack {
//                ForEach(viewmo, content: <#T##(Binding<Identifiable>) -> _#>)
                
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

class PllStatusViewModel: ObservableObject {
    private let paymentManager: BinkPaymentsManager
    
    @Published var loyaltyCardPllState: LoyaltyCardPLLState!

    init(paymentManager: BinkPaymentsManager) {
        self.paymentManager = paymentManager
    }
    
    func linkedPaymentCardsForLoyaltyCard() {
        if let loyaltyCard = paymentManager.loyaltyCard(from: 237193) {
            loyaltyCardPllState = paymentManager.pllStatus(for: loyaltyCard) { pllState in
                
            }
            
            
        }
    }
}
