//
//  LoyaltyCardView.swift
//  Test-DK
//
//  Created by Sean Williams on 24/01/2023.
//

import BinkPayments
import SwiftUI

struct LoyaltyCardView: View {
    @ObservedObject var viewModel = LoyaltyCardViewModel()
    
    var body: some View {
        if let loyaltyCard = viewModel.loyaltyCard {
            Text("Card Number: \(loyaltyCard.card?.cardNumber ?? loyaltyCard.card?.barcode ?? "")")
            Text("Loyalty Plan: \(BinkPaymentsManager.shared.loyaltyPlan?.planDetails?.companyName ?? "")")
        }
    }
}

struct LoyaltyCardView_Previews: PreviewProvider {
    static var previews: some View {
        LoyaltyCardView()
    }
}

class LoyaltyCardViewModel: ObservableObject {
    @Published var loyaltyCard: LoyaltyCardModel?
    
    init() {
        loyaltyCard = BinkPaymentsManager.shared.loyaltyCard()
    }
}
