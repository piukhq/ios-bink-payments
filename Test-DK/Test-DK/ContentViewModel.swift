//
//  ContentViewModel.swift
//  Test-DK
//
//  Created by Sean Williams on 24/01/2023.
//

import BinkPayments
import Foundation

class ContentViewModel {
    let paymentsManager = BinkPaymentsManager.shared
    let token = "eyJhbGciOiJIUzUxMiIsImtpZCI6ImFjY2Vzcy1zZWNyZXQtMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEyMTk5MiwiY2hhbm5lbCI6ImNvbS5sbG95ZHMuYXBpMiIsImlzX3Rlc3RlciI6ZmFsc2UsImlzX3RydXN0ZWRfY2hhbm5lbCI6ZmFsc2UsImlhdCI6MTY3NDU1NTMyNSwiZXhwIjoxNjc0NTU4OTI1fQ.8O6nPQERGd5kgLXVzuCnnpKnEG6GlsPtk8KBD4_XzKXFB8TuIP11e4tg5t6rZguypCJYsYCv1_MujMxqXWZaqQ"
    let refreshToken = "eyJhbGciOiJIUzUxMiIsImtpZCI6InJlZnJlc2gtYWNjZXNzLXNlY3JldC0yIiwidHlwIjoiSldUIn0.eyJzdWIiOjEyMTk5MiwiY2hhbm5lbCI6ImNvbS5sbG95ZHMuYXBpMiIsImNsaWVudF9pZCI6IjhlQmlMNVZoN0FLS2tXT2V6VzVBdnY4b2xmaEszdG85VG9xaXlwelBiT2lCajVYRUl2IiwiZ3JhbnRfdHlwZSI6ImIyYiIsImV4dGVybmFsX2lkIjoid2lsbGlhbXNfMjIzMyIsImlhdCI6MTY3NDU1NTMyNSwiZXhwIjoxNjc0NTU4OTI1fQ.2UuT9G15-PGcQHPXHIm2AX-4eAciJSqUQiuQeVgmaZDaquiqBbIyLFaR1yYRYrhyKH1NtVJay4bDHyZcR1SxCg"


    init() {
        let config = Configuration(testLoyaltyPlanID: "105", productionLoyaltyPlanID: "105", trustedCredentialType: .add)
        
        paymentsManager.configure(
            token: token,
            refreshToken: refreshToken,
            environmentKey: "1Lf7DiKgkcx5Anw7QxWdDxaKtTa",
            configuration: config,
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
            isDebug: true)
        
        if let loyaltyCard = BinkPaymentsManager.shared.loyaltyCard(from: 254957) {
            let _ = BinkPaymentsManager.shared.pllStatus(for: loyaltyCard, refreshedLinkedState: { _ in
                showSuccess()
            })
        }
    }
}
