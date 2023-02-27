//
//  ContentViewModel.swift
//  Test-DK
//
//  Created by Sean Williams on 24/01/2023.
//

import BinkPayments
import Foundation

class ContentViewModel: ObservableObject {
    private let successStatusRange = 200...299
    let paymentsManager = BinkPaymentsManager.shared
    var token = "eyJhbGciOiJIUzUxMiIsImtpZCI6ImFjY2Vzcy1zZWNyZXQtMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEyNDc1MywiY2hhbm5lbCI6ImNvbS50cnVzdGVkLmJpbmsud2FsbGV0IiwiaXNfdGVzdGVyIjpmYWxzZSwiaXNfdHJ1c3RlZF9jaGFubmVsIjp0cnVlLCJpYXQiOjE2NzUxNTg1NzgsImV4cCI6MTY3NTE2MDM3OH0.V_y3OrtX-Z4wKTNdmDUxxP0e4fsZFa1T9vBaJJuUTFIGoXqWsIzbSyJFbgW9GEl1YWTAR0nt_uhImXmpDSwM7w"
    var refreshToken = "eyJhbGciOiJIUzUxMiIsImtpZCI6InJlZnJlc2gtYWNjZXNzLXNlY3JldC0yIiwidHlwIjoiSldUIn0.eyJzdWIiOjEyNDc1MywiY2hhbm5lbCI6ImNvbS50cnVzdGVkLmJpbmsud2FsbGV0IiwiY2xpZW50X2lkIjoiRmtuUGMxWjY0MlNMM3VVdWVpTFU2OE5WTUNGOWlOdXpkSnVjclF4elh3eU5YSUFsN2wiLCJncmFudF90eXBlIjoiYjJiIiwiZXh0ZXJuYWxfaWQiOiJpYW11bmlxdWUyNW16bnhiYyIsImlhdCI6MTY3NzI1ODM2MCwiZXhwIjoxNjc3MjYxOTYwfQ.uSwGvbgWD9tVHMUGUyF51fOxMmCVhGroFSAi82EDeEVvPDGuf1AHgHx8KLKfJxTlpofRXBqsmdT2xDgVJgBu6w"
    

    init() {
        paymentsManager.delegate = self
        configureSDK()
    }
    
    func triggerTokenRefresh(showSuccess: @escaping () -> Void) {
        BinkPaymentsManager.shared.configure(
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: LoyaltyPlanConfiguration(testLoyaltyPlanID: "286",
                                         productionLoyaltyPlanID: "286",
                                         trustedCredentialType: .authorise),
            email: "risilva10223@gmail.com",
            isDebug: true)
        
        if let loyaltyCard = BinkPaymentsManager.shared.loyaltyCard {
            let _ = BinkPaymentsManager.shared.pllStatus(for: loyaltyCard, refreshedLinkedState: { _ in
                showSuccess()
            })
        }
    }
    
    func setTrustedCard(id: String) {
        paymentsManager.set(loyaltyId: .email, accountId: id)
    }
    
    func replaceTrustedCard(id: String) {
        paymentsManager.replace(loyaltyId: .email, accountId: id)
    }
    
    func updateTokens(token: String, refreshToken: String) {
        self.token = token
        self.refreshToken = refreshToken
        configureSDK()
    }
    
    private func configureSDK() {
        let config = LoyaltyPlanConfiguration(testLoyaltyPlanID: "286", productionLoyaltyPlanID: "286", trustedCredentialType: .authorise)
        paymentsManager.configure(
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: config,
            email: "risilva10223@gmail.com",
            isDebug: true)
        
        paymentsManager.setToken(token: token, refreshToken: refreshToken)
    }
}

extension ContentViewModel: BinkPaymentsManagerDelegate {
    func apiResponseNotification(_ notification: NSNotification) {
        if let response = notification.userInfo as? [String: String] {
            let statusCode = response["statusCode"] ?? ""
            let endpoint = String(response["endpoint"]?.dropFirst(8) ?? "")
            let success = successStatusRange.contains(Int(statusCode) ?? 0)
            MessageView.show(statusCode + ": " + endpoint, type: .responseCodeVisualizer(success ? .success : .failure))
        }
    }
}
