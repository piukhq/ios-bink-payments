//
//  WalletService.swift
//  
//
//  Created by Sean Williams on 30/11/2022.
//

import Foundation


/// Used when there isn't an object being passed into the completion handler, just a success bool where it makes sense not to complicate things with Result.
typealias ServiceCompletionSuccessHandler<ErrorType: BinkError> = (Bool, ErrorType?) -> Void

typealias ServiceCompletionSuccessResponseDataHandler<ErrorType: BinkError> = (Bool, ErrorType?, NetworkResponseData?) -> Void

/// Used when we need to pass an object or set of objects through the completion handler rather than just a success bool.
typealias ServiceCompletionResultHandler<ObjectType: Any, ErrorType: BinkError> = (Result<ObjectType, ErrorType>) -> Void

/// Used when we need to pass an object or set of objects through the completion handler rather than just a success bool, and the completion handler requires context of the raw http response.
typealias ServiceCompletionResultRawResponseHandler<ObjectType: Any, ErrorType: BinkError> = (Result<ObjectType, ErrorType>, NetworkResponseData?) -> Void


class WalletService {
    private let apiClient = APIClient()

    func getLoyaltyPlans(completion: @escaping ServiceCompletionResultHandler<[LoyaltyPlanModel], WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .plans, method: .get, headers: nil, isUserDriven: true)
        apiClient.performRequest(request, expecting: [Safe<LoyaltyPlanModel>].self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                let safeResponse = response.compactMap { $0.value }

                completion(.success(safeResponse))
            case .failure(let error):
                completion(.failure(.failedToGetLoyaltyPlans(error)))
            }
        }
    }
    
    func getSpreedlyToken(withRequest model: SpreedlyRequest, completion: @escaping ServiceCompletionResultHandler<SpreedlyResponse, WalletServiceError>) {
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
    
    func addPaymentCard(withRequestModel model: PaymentCardCreateRequest, completion: @escaping ServiceCompletionResultRawResponseHandler<PaymentAccountResponseModel, WalletServiceError>) {
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .createPaymentAccount, method: .post, headers: nil, isUserDriven: true)
        apiClient.performRequestWithBody(binkNetworkRequest, body: model, expecting: Safe<PaymentAccountResponseModel>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    completion(.failure(.customError("Failed to decode new payment card")), rawResponse)
                    return
                }
                completion(.success(safeResponse), rawResponse)
            case .failure:
                completion(.failure(.failedToAddPaymentCard), rawResponse)
            }
        }
        
    }
    
    func getWalletFromAPI(completion: @escaping ServiceCompletionResultHandler<WalletModel, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .wallet, method: .get, isUserDriven: false)
        apiClient.performRequest(request, expecting: Safe<WalletModel>.self) { result, rawResponse in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    completion(.failure(.failedToDecodeWallet))
                    return
                }
                completion(.success(safeResponse))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(.failedToGetWallet))
            }
        }
    }
}
