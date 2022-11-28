//
//  PaymentWalletRepository.swift
//  
//
//  Created by Sean Williams on 23/11/2022.
//

import Foundation

class PaymentWalletRepository {
    private let apiClient = APIClient()
    
    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, onSuccess: @escaping (PaymentCardResponseModel) -> Void, onError: @escaping(NetworkingError?) -> Void) {
        if BinkPaymentsManager.shared.isTesting {
            createPaymentCard(paymentCard, onSuccess: { createdPaymentCard in
                onSuccess(createdPaymentCard)
            }, onError: { error in
                onError(error)
            })
        } else {
            requestSpreedlyToken(paymentCard: paymentCard, onSuccess: { [weak self] spreedlyResponse in
                guard spreedlyResponse.isValid else {
                    onError(nil)
                    return
                }
                
                self?.createPaymentCard(paymentCard, spreedlyResponse: spreedlyResponse, onSuccess: { createdPaymentCard in
                    onSuccess(createdPaymentCard)
                }, onError: { error in
                    onError(error)
                })
            }) { error in
                onError(error)
            }
            return
        }
    }
    
    private func requestSpreedlyToken(paymentCard: PaymentCardCreateModel, onSuccess: @escaping (SpreedlyResponse) -> Void, onError: @escaping (NetworkingError) -> Void) {
        let spreedlyRequest = SpreedlyRequest(fullName: paymentCard.nameOnCard, number: paymentCard.fullPan, month: paymentCard.month, year: paymentCard.year)

        getSpreedlyToken(withRequest: spreedlyRequest) { result in
            switch result {
            case .success(let response):
                onSuccess(response)
            case .failure(let error):
                onError(error)
            }
        }
    }

    private func createPaymentCard(_ paymentCard: PaymentCardCreateModel, spreedlyResponse: SpreedlyResponse? = nil, onSuccess: @escaping (PaymentCardResponseModel) -> Void, onError: @escaping(NetworkingError?) -> Void) {
        var paymentCreateRequest: PaymentCardCreateRequest?

        if let spreedlyResponse = spreedlyResponse {
            paymentCreateRequest = PaymentCardCreateRequest(spreedlyResponse: spreedlyResponse, paymentAccount: paymentCard)
        } else {
            paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard)
        }

        guard let paymentCreateRequest = paymentCreateRequest else {
            onError(nil)
            return
        }

        
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .createPaymentAccount, method: .post, headers: nil, isUserDriven: true)
        apiClient.performRequestWithBody(binkNetworkRequest, body: paymentCreateRequest, expecting: Safe<PaymentCardResponseModel>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    onError(nil)
                    return
                }
                onSuccess(safeResponse)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    func getSpreedlyToken(withRequest model: SpreedlyRequest, completion: @escaping (Result<SpreedlyResponse, NetworkingError>) -> Void) {
        let request = BinkNetworkRequest(endpoint: .spreedly, method: .post, headers: nil, isUserDriven: true)
        apiClient.performRequestWithBody(request, body: model, expecting: Safe<SpreedlyResponse>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    completion(.failure(.customError("Failed to decode spreedly response")))
                    return
                }
                completion(.success(safeResponse))
            case .failure:
                completion(.failure(.failedToGetSpreedlyToken))
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
