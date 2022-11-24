//
//  PaymentWalletRepository.swift
//  
//
//  Created by Sean Williams on 23/11/2022.
//

import Foundation

class PaymentWalletRepository {
    private let apiClient = APIClient()
    private var isProduction = false
    
    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        if BinkPaymentsManager.shared.isTesting {
            createPaymentCard(paymentCard, onSuccess: {
                onSuccess()
            }, onError: {
                onError()
            })
        } else {
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

    private func createPaymentCard(_ paymentCard: PaymentCardCreateModel, spreedlyResponse: SpreedlyResponse? = nil, onSuccess: @escaping () -> Void, onError: @escaping() -> Void) {
        var paymentCreateRequest: PaymentCardCreateRequest?

        if let spreedlyResponse = spreedlyResponse {
            paymentCreateRequest = PaymentCardCreateRequest(spreedlyResponse: spreedlyResponse, paymentAccount: paymentCard)
        } else {
            paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard)
        }

        guard let paymentCreateRequest = paymentCreateRequest else {
            onError()
            return
        }

        
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .createPaymentAccount, method: .post, headers: nil, isUserDriven: true)
        apiClient.performRequestWithBody(binkNetworkRequest, body: paymentCreateRequest, expecting: Safe<PaymentCardResponseModel>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    onError()
                    return
                }

                onSuccess()
            case .failure:
                onError()
            }
        }
    }
}

struct Safe<Base: Decodable>: Decodable {
    let value: Base?

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Base.self)
        } catch {
            self.value = nil
            print(String(describing: error))
        }
    }
}
