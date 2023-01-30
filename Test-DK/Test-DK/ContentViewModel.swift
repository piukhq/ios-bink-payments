//
//  ContentViewModel.swift
//  Test-DK
//
//  Created by Sean Williams on 24/01/2023.
//

import BinkPayments
import Foundation

class ContentViewModel {
    private let successStatusRange = 200...299
    let paymentsManager = BinkPaymentsManager.shared
    let token = "eyJhbGciOiJIUzUxMiIsImtpZCI6ImFjY2Vzcy1zZWNyZXQtMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEyMTk5MiwiY2hhbm5lbCI6ImNvbS5sbG95ZHMuYXBpMiIsImlzX3Rlc3RlciI6ZmFsc2UsImlzX3RydXN0ZWRfY2hhbm5lbCI6ZmFsc2UsImlhdCI6MTY3NDU3OTI4NCwiZXhwIjoxNjc0NTgyODg0fQ.Tq19-jBJ4gt0wO3H4Bs8ozH5Ek-J-6keQmWORN-L6BywQpU_2tPXDXqfeuXh4NeSibBqS-y1sWGBr_xSqGdy-Q"
    let refreshToken = "eyJhbGciOiJIUzUxMiIsImtpZCI6InJlZnJlc2gtYWNjZXNzLXNlY3JldC0yIiwidHlwIjoiSldUIn0.eyJzdWIiOjEyMTk5MiwiY2hhbm5lbCI6ImNvbS5sbG95ZHMuYXBpMiIsImNsaWVudF9pZCI6IjhlQmlMNVZoN0FLS2tXT2V6VzVBdnY4b2xmaEszdG85VG9xaXlwelBiT2lCajVYRUl2IiwiZ3JhbnRfdHlwZSI6ImIyYiIsImV4dGVybmFsX2lkIjoid2lsbGlhbXNfMjIzMyIsImlhdCI6MTY3NDU3OTI4NCwiZXhwIjoxNjc0NTgyODg0fQ.V0t1_bdPRC9pj97FhhxmWRUU3jaahT_59jVr7Xis76Am2oWmOmcERec0a-PbIEiOAU-uy--yuEk6GaIDSbneAQ"


    init() {
        let config = Configuration(testLoyaltyPlanID: "105", productionLoyaltyPlanID: "105", trustedCredentialType: .add)
        paymentsManager.delegate = self
        paymentsManager.configure(
            token: token,
            refreshToken: refreshToken,
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: config,
            email: "binktest1@bink.com",
            isDebug: true)
    }
    
    func triggerTokenRefresh(showSuccess: @escaping () -> Void) {
        BinkPaymentsManager.shared.configure(
            token: "ExpiredToken",
            refreshToken: refreshToken,
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: Configuration(testLoyaltyPlanID: "105",
                                         productionLoyaltyPlanID: "105",
                                         trustedCredentialType: .authorise),
            email: "binktest1@bink.com",
            isDebug: true)
        
        if let loyaltyCard = BinkPaymentsManager.shared.loyaltyCard() {
            let _ = BinkPaymentsManager.shared.pllStatus(for: loyaltyCard, refreshedLinkedState: { _ in
                showSuccess()
            })
        }
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
