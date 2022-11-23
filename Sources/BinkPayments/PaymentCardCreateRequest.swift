//
//  File.swift
//  
//
//  Created by Sean Williams on 23/11/2022.
//

import Foundation

struct PaymentCardCreateRequest: Codable {
    let token: String
    let firstSixDigits: String
    let lastFourDigits: String
    let nameOnCard: String
    let month: String
    let year: String
    let fingerprint: String
    let cardNickname: String?
    
    enum CodingKeys: String, CodingKey {
        case token
        case firstSixDigits = "first_six_digits"
        case lastFourDigits = "last_four_digits"
        case nameOnCard = "name_on_card"
        case month = "expiry_month"
        case year = "expiry_year"
        case fingerprint
        case cardNickname = "card_nickname"
    }
    
    /// This should only be used for creating test payment cards as it naturally bypasses the Spreedly path
    init?(model: PaymentCardCreateModel) {
        guard let pan = model.fullPan?.replacingOccurrences(of: " ", with: ""),
            let year = model.year,
            let month = model.month
            else { return nil }
        
        var firstSix: String?
        var lastFour: String?
        if let firstSixEndIndex = pan.index(pan.startIndex, offsetBy: 6, limitedBy: pan.endIndex),
            let lastFourStartIndex = pan.index(pan.endIndex, offsetBy: -4, limitedBy: pan.startIndex) {
            firstSix = String(pan[pan.startIndex..<firstSixEndIndex])
            lastFour = String(pan[lastFourStartIndex..<pan.endIndex])
        }

        
        self.token = PaymentCardCreateRequest.fakeToken()
        self.firstSixDigits = firstSix ?? ""
        self.lastFourDigits = lastFour ?? ""
        self.nameOnCard = model.nameOnCard ?? ""
        self.month = String(month)
        self.year = String(year)
        self.fingerprint = PaymentCardCreateRequest.fakeFingerprint(pan: pan, expiryYear: String(year), expiryMonth: String(month))
        self.cardNickname = model.cardNickname
    }

    /// This should only be used for creating genuine payment cards using Spreedly path in a production environment
    init?(spreedlyResponse: SpreedlyResponse, paymentAccount: PaymentCardCreateModel) {
        let paymentMethodResponse = spreedlyResponse.transaction?.paymentMethod
        
        self.token = paymentMethodResponse?.token ?? ""
        self.firstSixDigits = paymentMethodResponse?.firstSix ?? ""
        self.lastFourDigits = paymentMethodResponse?.lastFour ?? ""
        self.nameOnCard = paymentMethodResponse?.fullName ?? ""
        self.month = String(paymentMethodResponse?.month ?? 0)
        self.year = String(paymentMethodResponse?.year ?? 0)
        self.fingerprint = paymentMethodResponse?.fingerprint ?? ""
        self.cardNickname = paymentAccount.cardNickname
    }
    
    private static func fakeFingerprint(pan: String, expiryYear: String, expiryMonth: String) -> String {
        // Based a hash of the pan, it's the key identifier of the card
        let stringToHash = "\(pan)|\(expiryMonth)|\(expiryYear)"
        return "TEST " + stringToHash.sha256
    }
    
    private static func fakeToken() -> String {
        // A random string per request
        return String.randomString(length: 100)
    }
}
