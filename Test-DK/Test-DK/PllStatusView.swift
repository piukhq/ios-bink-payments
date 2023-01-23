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

class PllStatusViewModel: ObservableObject {
    private let paymentManager: BinkPaymentsManager
    
    @Published var loyaltyCardPllState: LoyaltyCardPLLState!
    @Published var paymentAccountPllState: PaymentAccountPLLState!

    init(paymentManager: BinkPaymentsManager) {
        self.paymentManager = paymentManager
    }
    
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
