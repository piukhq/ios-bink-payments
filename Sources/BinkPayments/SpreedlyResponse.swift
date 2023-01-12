//
//  SpreedlyResponse.swift
//  
//
//  Created by Sean Williams on 23/11/2022.
//

import Foundation

struct SpreedlyRequest: Codable {
    struct PaymentMethod: Codable {
        struct CreditCard: Codable {
            let fullName: String?
            let number: String?
            let month: Int?
            let year: Int?

            enum CodingKeys: String, CodingKey {
                case fullName = "full_name"
                case number
                case month
                case year
            }
        }

        let creditCard: CreditCard?

        enum CodingKeys: String, CodingKey {
            case creditCard = "credit_card"
        }
    }

    let paymentMethod: PaymentMethod?

    init(fullName: String?, number: String?, month: Int?, year: Int?) {
        let creditCard = PaymentMethod.CreditCard(fullName: fullName, number: number, month: month, year: year)
        paymentMethod = PaymentMethod(creditCard: creditCard)
    }

    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
    }
}

struct SpreedlyResponse: Codable {
    var transaction: Transaction?

    struct Transaction: Codable {
        var paymentMethod: PaymentMethod?
        var state: String?
        var succeeded: Bool?

        enum CodingKeys: String, CodingKey {
            case paymentMethod = "payment_method"
            case state
            case succeeded
        }

        struct PaymentMethod: Codable {
            var token: String?
            var lastFour: String?
            var firstSix: String?
            var fingerprint: String?
            var fullName: String?
            var month: Int?
            var year: Int?
            var errors: [SpreedlyError]?

            enum CodingKeys: String, CodingKey {
                case token
                case lastFour = "last_four_digits"
                case firstSix = "first_six_digits"
                case fingerprint
                case fullName = "full_name"
                case month
                case year
                case errors
            }

            struct SpreedlyError: Codable {
                var attribute: String?
                var key: String?
                var message: String?
            }
        }
    }

    var isValid: Bool {
        // Even if we get a 200/201 response, it may not be valid
        guard let transaction = transaction else {
            return false
        }
        guard let paymentMethod = transaction.paymentMethod else {
            return false
        }
        guard transaction.state == "succeeded" || transaction.succeeded == true else {
            return false
        }
        guard let errors = paymentMethod.errors else {
            return true
        }
        guard errors.isEmpty else {
            return false
        }
        return true
    }
}
