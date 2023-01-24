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
                        showTriggerTokenRefreshAlert = true
                    }
                    
                    NavigationLink(destination: PllStatusView(), tag: 0, selection: $viewSelection) { EmptyView() }
                    NavigationLink(destination: Text("Bello"), tag: 1, selection: $viewSelection) { EmptyView() }
                    NavigationLink(destination: Text("Yooooo"), tag: 2, selection: $viewSelection) { EmptyView() }
                    
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
