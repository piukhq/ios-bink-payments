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
                    
                    NavigationLink(destination: PllStatusView(), tag: 0, selection: $viewSelection) { EmptyView() }
                    NavigationLink(destination: Text("Bello"), tag: 1, selection: $viewSelection) { EmptyView() }
                    NavigationLink(destination: Text("Yooooo"), tag: 2, selection: $viewSelection) { EmptyView() }
                    
                }
                .padding()
                .alert("Coming Soon", isPresented: $showAlert) {}
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
        let config = Configuration(testLoyaltyPlanID: "105", productionLoyaltyPlanID: "105", trustedCredentialType: .add)
        
        paymentsManager.configure(
            token: "eyJhbGciOiJIUzUxMiIsImtpZCI6ImFjY2Vzcy1zZWNyZXQtMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEyMTk5MiwiY2hhbm5lbCI6ImNvbS5sbG95ZHMuYXBpMiIsImlzX3Rlc3RlciI6ZmFsc2UsImlzX3RydXN0ZWRfY2hhbm5lbCI6ZmFsc2UsImlhdCI6MTY3NDQ3NTA2NSwiZXhwIjoxNjc0NDc4NjY1fQ.Mj_2MVE-WzWsVi_b7Q8cOPL6ul0e6f_EWOHG897TvhxCbAW9WYRurwsSw_tcO0a2JZjbL8d3tkk4SvcImGtX-A",
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: config,
            isDebug: true)
    }
}
