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
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
            VStack {
                BinkButton(text: "Add Payment Card") {
                    viewModel.paymentsManager.launchScanner()
                }
                
                BinkButton(text: "Show Payment Cards") {
                    showAlert = true
                }
                
                BinkButton(text: "Set Loyalty Card") {
                    
                }
                
                BinkButton(text: "Replace Loyalty Card") {
                    
                }
                
                BinkButton(text: "Show Loyalty Card") {
                    showAlert = true
                }
                
                BinkButton(text: "Am I PLL Linked?") {
                    
                }
                
                BinkButton(text: "Trigger Token Refresh") {
                    
                }
                
            }
            .padding()
            .alert("Coming Soon", isPresented: $showAlert) {}
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
            token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiIsImtpZCI6ImFjY2Vzcy1zZWNyZXQtMiJ9.eyJzdWIiOjM4MjgzLCJjaGFubmVsIjoiY29tLmJpbmsud2FsbGV0IiwiaWF0IjoxNjUxMTUyOTU5LCJleHAiOjE2ODI2ODg5NTl9.mvcKT3eALLCOENFIWl39Zo6t5Jux8RVuMH0-nawnjNPjv5tGALlpM6-gNcPtdXEB6_ZL_uJAmaJZNT4h1V-yYw",
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: config,
            isDebug: true)
    }
}
