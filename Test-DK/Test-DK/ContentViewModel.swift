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
    let token = "eyJhbGciOiJIUzUxMiIsImtpZCI6ImFjY2Vzcy1zZWNyZXQtMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEyMTk5MiwiY2hhbm5lbCI6ImNvbS5sbG95ZHMuYXBpMiIsImlzX3Rlc3RlciI6ZmFsc2UsImlzX3RydXN0ZWRfY2hhbm5lbCI6ZmFsc2UsImlhdCI6MTY3NTA5ODY4NSwiZXhwIjoxNjc1MTAyMjg1fQ.I7QuMIkTsI32etrrq8x5t4Ob8KzZcjYyJU0Nz_4-Fh1WQVcVdyESoZOp048-oHMqbEcp8L1LGNXnRRUHwn6JDw"
    let refreshToken = "eyJhbGciOiJIUzUxMiIsImtpZCI6InJlZnJlc2gtYWNjZXNzLXNlY3JldC0yIiwidHlwIjoiSldUIn0.eyJzdWIiOjEyMTk5MiwiY2hhbm5lbCI6ImNvbS5sbG95ZHMuYXBpMiIsImNsaWVudF9pZCI6IjhlQmlMNVZoN0FLS2tXT2V6VzVBdnY4b2xmaEszdG85VG9xaXlwelBiT2lCajVYRUl2IiwiZ3JhbnRfdHlwZSI6ImIyYiIsImV4dGVybmFsX2lkIjoid2lsbGlhbXNfMjIzMyIsImlhdCI6MTY3NTA5ODY4NSwiZXhwIjoxNjc1MTAyMjg1fQ.TQqREmStbcCDveZ44vmrON1-22t9Sx9-xb2hDjWolhatXC3J8-9ETPDL_g2ZzqfRVVdp8f9ySqguXTnYEACfBw"
    
    @Published var loyaltyCardDidUpdate = false


    init() {
        let config = Configuration(testLoyaltyPlanID: "286", productionLoyaltyPlanID: "286", trustedCredentialType: .add)
        paymentsManager.delegate = self
        paymentsManager.configure(
            token: token,
            refreshToken: refreshToken,
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: config,
            email: "risilva10223@gmail.com",
            isDebug: true)
    }
    
    func triggerTokenRefresh(showSuccess: @escaping () -> Void) {
        BinkPaymentsManager.shared.configure(
            token: "ExpiredToken",
            refreshToken: refreshToken,
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: Configuration(testLoyaltyPlanID: "286",
                                         productionLoyaltyPlanID: "286",
                                         trustedCredentialType: .authorise),
            email: "risilva10223@gmail.com",
            isDebug: true)
        
        if let loyaltyCard = BinkPaymentsManager.shared.loyaltyCard() {
            let _ = BinkPaymentsManager.shared.pllStatus(for: loyaltyCard, refreshedLinkedState: { _ in
                showSuccess()
            })
        }
    }
    
    func setTrustedCard(id: String) {
        paymentsManager.set(loyaltyIdentity: id) {
            self.loyaltyCardDidUpdate = true
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
