//
//  ContentView.swift
//  Test-DK
//
//  Created by Sean Williams on 17/01/2023.
//

import SwiftUI
import BinkPayments

struct ContentView: View {
    let viewModel = ViewModel()
    @State private var showAlert = false
    @State private var viewSelection: Int? = nil
//    @State private var pllStatusSelection = true
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    BinkButton(text: "Add Payment Card") {
                        viewModel.paymentsManager.launchScanner()
                    }
                    
                    BinkButton(text: "Show Payment Cards") {
                        showAlert = true
                    }
                    
                    BinkButton(text: "Set Loyalty Card") {
                        viewSelection = 2
                    }
                    
                    BinkButton(text: "Replace Loyalty Card") {
                        
                    }
                    
                    BinkButton(text: "Show Loyalty Card") {
                        showAlert = true
                    }
                    
                    BinkButton(text: "Am I PLL Linked?") {
                        viewSelection = 0
                    }
                    
                    BinkButton(text: "Trigger Token Refresh") {
                        viewSelection = 1
                    }
                    
                    NavigationLink(destination: PllStatusView(viewModel: PllStatusViewModel(paymentManager: viewModel.paymentsManager)), tag: 0, selection: $viewSelection) { EmptyView() }
                    NavigationLink(destination: Text("Bello"), tag: 1, selection: $viewSelection) { EmptyView() }
                    NavigationLink(destination: Text("Yooooo"), tag: 2, selection: $viewSelection) { EmptyView() }
                    
                }
                .padding()
                .alert("Coming Soon", isPresented: $showAlert) {}
//                .alert(isPresented: $pllStatusSelection) {
//                    Alert(
//                        title: Text(""),
//                        primaryButton: .default(Text("Loyalty")),
//                        secondaryButton: .default(Text("Payment"))
//                        )
//                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BinkButton: View {
    var text: String
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .frame(minWidth: 0, maxWidth: .infinity)

        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.pink)
    }
}

class ViewModel {
    let paymentsManager = BinkPaymentsManager.shared

    init() {
        let config = Configuration(testLoyaltyPlanID: "203", productionLoyaltyPlanID: "203", trustedCredentialType: .add)
        
        paymentsManager.configure(
            token: "eyJhbGciOiJIUzUxMiIsImtpZCI6ImFjY2Vzcy1zZWNyZXQtMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEyMTk5MiwiY2hhbm5lbCI6ImNvbS5sbG95ZHMuYXBpMiIsImlzX3Rlc3RlciI6ZmFsc2UsImlzX3RydXN0ZWRfY2hhbm5lbCI6ZmFsc2UsImlhdCI6MTY3NDQ2NjY3NywiZXhwIjoxNjc0NDcwMjc3fQ.4cVWiZjCH2ISHjWV8vnpFmSNg-btsr4CFg4JdYE8RUK2hJDWXlTdUMRweaX-EiQcLCNCSErCijaBy34XExX06Q",
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: config,
            isDebug: true)
    }
}
