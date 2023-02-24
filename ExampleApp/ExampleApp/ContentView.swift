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
    @State private var showSetTrustedAlert = false
    @State private var showReplaceTrustedAlert = false
    @State private var showTriggerTokenRefreshAlert = false
    @State private var showTokenRefreshSuccessAlert = false
    @State private var setIDTextfieldText = ""
    @State private var replaceIDTextfieldText = ""
    @State private var showAddTokenAlert = false
    @State private var tokenTextfieldText = ""
    @State private var tokenRefreshTextfieldText = ""

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
                        showSetTrustedAlert = true
                    }

                    BinkButton(text: "Replace Loyalty Card") {
                        showReplaceTrustedAlert = true
                    }

                    NavigationLink {
                        LoyaltyCardView(viewModel: LoyaltyCardViewModel())
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
                    
                    Spacer()
                        .frame(height:20)

                    Button {
                        showAddTokenAlert = true
                    } label: {
                        Text("Update SDK Tokens")
                    }
                }
                .padding()
                
                .alert("Coming Soon", isPresented: $showAlert) {}
                .alert("Set loyalty ID of new card", isPresented: $showSetTrustedAlert, actions: {
                    TextField("ID", text: $setIDTextfieldText)
                    Button("OK") {
                        viewModel.setTrustedCard(id: setIDTextfieldText)
                    }
                    Button("Cancel", role: .cancel) {}
                })
                .alert("Replace loyalty ID of current card", isPresented: $showReplaceTrustedAlert, actions: {
                    TextField("ID", text: $replaceIDTextfieldText)
                    Button("OK") {
                        viewModel.replaceTrustedCard(id: replaceIDTextfieldText)
                    }
                    Button("Cancel", role: .cancel) {}
                })
                
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
                .alert("Replace tokens", isPresented: $showAddTokenAlert, actions: {
                    TextField("Token", text: $tokenTextfieldText)
                        .frame(height: 200)
                    TextField("Refresh Token", text: $tokenRefreshTextfieldText)
                        .frame(height: 200)
                    Button("OK") {
                        viewModel.updateTokens(token: tokenTextfieldText, refreshToken: tokenRefreshTextfieldText)
                    }
                    Button("Cancel", role: .cancel) {}
                })
            }
        }
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
