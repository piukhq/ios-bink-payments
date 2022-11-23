//
//  PaymentWalletRepository.swift
//  
//
//  Created by Sean Williams on 23/11/2022.
//

import Foundation

class PaymentWalletRepository {
    var isProduction = false
    
    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        if isProduction {
//            requestSpreedlyToken(paymentCard: paymentCard, onSuccess: { [weak self] spreedlyResponse in
//                guard spreedlyResponse.isValid else {
//                    onError(nil)
//                    return
//                }
//                self?.createPaymentAccount(paymentCard, spreedlyResponse: spreedlyResponse, onSuccess: { createdPaymentCard in
//                    onSuccess(createdPaymentCard)
//                }, onError: { error in
//                    onError(error)
//                })
//            }) { error in
//                onError(error)
//            }
//            return
        } else {
            createPaymentAccount(paymentCard, onSuccess: {
                onSuccess()
            }, onError: {
                onError()
            })
        }
    }
    
//    private func requestSpreedlyToken(paymentCard: PaymentAccountCreateModel, onSuccess: @escaping (SpreedlyResponse) -> Void, onError: @escaping (BinkError?) -> Void) {
//        let spreedlyRequest = SpreedlyRequest(fullName: paymentCard.nameOnCard, number: paymentCard.fullPan, month: paymentCard.expiryMonth, year: paymentCard.expiryYear)
//
//        getSpreedlyToken(withRequest: spreedlyRequest) { result in
//            switch result {
//            case .success(let response):
//                onSuccess(response)
//            case .failure(let error):
//                onError(error)
//            }
//        }
//    }

    private func createPaymentAccount(_ paymentAccount: PaymentCardCreateModel, spreedlyResponse: SpreedlyResponse? = nil, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        var paymentCreateRequest: PaymentCardCreateRequest?

        if let spreedlyResponse = spreedlyResponse {
            paymentCreateRequest = PaymentCardCreateRequest(spreedlyResponse: spreedlyResponse, paymentAccount: paymentAccount)
        } else {
            paymentCreateRequest = PaymentCardCreateRequest(model: paymentAccount)
        }

        guard let request = paymentCreateRequest else {
            onError()
            return
        }

//        addPaymentCard(withRequestModel: request) { (result, responseData) in
//            switch result {
//            case .success(var response):
//                response.firstSix = paymentAccount.firstSixDigits
//                onSuccess()
//            case .failure(let error):
//                onError(error)
//            }
//        }
    }
}
