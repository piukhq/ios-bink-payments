//
//  LoyaltyCardView.swift
//  Test-DK
//
//  Created by Sean Williams on 24/01/2023.
//

import BinkPayments
import SwiftUI

struct LoyaltyCardView: View {
    @ObservedObject var viewModel: LoyaltyCardViewModel
    
    var body: some View {
        Text("Loyalty Card")
            .fontWeight(.bold)
            .onAppear() {
                viewModel.getLoyaltyCard()
            }

        if let loyaltyCard = viewModel.loyaltyCard {
            Text("Card Number: \(loyaltyCard.card?.cardNumber ?? loyaltyCard.card?.barcode ?? "")")
            Text("Loyalty Plan: \(BinkPaymentsManager.shared.loyaltyPlan?.planDetails?.companyName ?? "")")
        }
    }
}

struct LoyaltyCardView_Previews: PreviewProvider {
    static var previews: some View {
        LoyaltyCardView(viewModel: LoyaltyCardViewModel())
    }
}

class LoyaltyCardViewModel: ObservableObject {
    @Published var loyaltyCard: LoyaltyCardModel?

    func getLoyaltyCard() {
        loyaltyCard = BinkPaymentsManager.shared.loyaltyCard()
    }
}
