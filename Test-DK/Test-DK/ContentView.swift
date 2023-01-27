//
//  ContentView.swift
//  Test-DK
//
//  Created by Sean Williams on 17/01/2023.
//

import SwiftUI
import BinkPayments

struct ContentView: View {
    let viewModel = ContentViewModel()
    @State private var showAlert = false
    @State private var showTriggerTokenRefreshAlert = false
    @State private var showTokenRefreshSuccessAlert = false
//    @State private var viewSelection: Int? = nil
    
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
                        showAlert = true
                    }

                    NavigationLink {
                        LoyaltyCardView()
                    } label: {
                        NavigationLinkView(text: "Replace Loyalty Card")
                    }
                    .padding(.bottom, -1)

                    NavigationLink {
                        LoyaltyCardView()
                    } label: {
                        NavigationLinkView(text: "Show Loyalty Card")
                    }
                    .padding(.bottom, -1)
    
                    NavigationLink {
                        PllStatusView()
                    } label: {
                        NavigationLinkView(text: "Am I PLL Linked?")
                    }
                    .padding(.bottom, -1)
                    
                    BinkButton(text: "Trigger Token Refresh") {
                        showTriggerTokenRefreshAlert = true
                    }
                }
                .padding()
                
                .alert("Coming Soon", isPresented: $showAlert) {}
                .alert("Token Refresh Success", isPresented: $showTokenRefreshSuccessAlert) {}
                .alert("Token Refresh", isPresented: $showTriggerTokenRefreshAlert) {
                    Button("OK") {
                        viewModel.triggerTokenRefresh {
                            showTokenRefreshSuccessAlert = true
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Replace current token with expired token to trigger token refresh?")
                }
            }
        }
        .navigationTitle("SEAN")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct NavigationLinkView: View {
    var text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.pink)
                .frame(height: 50)
                .padding(0)
            Text(text)
                .foregroundColor(.white)
        }
    }
}

struct BinkButton: View {
    var text: String
    var action: (() -> ())?
    
    var body: some View {
        Button {
            action?()
        } label: {
            Text(text)
                .frame(minWidth: 0, maxWidth: .infinity)

        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.pink)
    }
}
