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
    
    var body: some View {
        VStack {
            Button {
                viewModel.paymentsManager.launchScanner(delegate: viewModel)
            } label: {
                Text("Add Payment Card")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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

extension ViewModel: BinkScannerViewControllerDelegate {
    func binkScannerViewControllerShouldEnterManually(_ viewController: BinkPayments.BinkScannerViewController, completion: (() -> Void)?) {
        paymentsManager.launchAddPaymentCardScreen()
    }
    
    func binkScannerViewController(_ viewController: BinkPayments.BinkScannerViewController, didScan paymentCard: BinkPayments.PaymentAccountCreateModel) {
        print("Did scan")
    }
    
    
}
