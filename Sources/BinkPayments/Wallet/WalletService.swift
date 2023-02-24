//
//  WalletService.swift
//  
//
//  Created by Sean Williams on 30/11/2022.
//

import Alamofire
import Foundation


/// Used when there isn't an object being passed into the completion handler, just a success bool where it makes sense not to complicate things with Result.
typealias ServiceCompletionSuccessHandler<ErrorType: BinkError> = (Bool, ErrorType?) -> Void

typealias ServiceCompletionSuccessResponseDataHandler<ErrorType: BinkError> = (Bool, ErrorType?, NetworkResponseData?) -> Void

/// Used when we need to pass an object or set of objects through the completion handler rather than just a success bool.
typealias ServiceCompletionResultHandler<ObjectType: Any, ErrorType: BinkError> = (Result<ObjectType, ErrorType>) -> Void

/// Used when we need to pass an object or set of objects through the completion handler rather than just a success bool, and the completion handler requires context of the raw http response.
typealias ServiceCompletionResultRawResponseHandler<ObjectType: Any, ErrorType: BinkError> = (Result<ObjectType, ErrorType>, NetworkResponseData?) -> Void

class WalletServiceProtocol {}

extension WalletServiceProtocol {
    func getLoyaltyPlan(for id: String, completion: @escaping ServiceCompletionResultHandler<LoyaltyPlanModel?, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .plan(id: id), method: .get, headers: nil)
        BinkPaymentsManager.shared.apiClient.performRequest(request, expecting: Safe<LoyaltyPlanModel>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                completion(.success(response.value))
            case .failure(let error):
                completion(.failure(.failedToGetLoyaltyPlan(error)))
            }
        }
    }
    
    func getSpreedlyToken(withRequest model: SpreedlyRequest, completion: @escaping ServiceCompletionResultHandler<SpreedlyResponse, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .spreedly, method: .post, headers: nil)
        BinkPaymentsManager.shared.apiClient.performRequestWithBody(request, body: model, expecting: Safe<SpreedlyResponse>.self) { (result, rawResponse) in
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
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .createPaymentAccount, method: .post, headers: nil)
        BinkPaymentsManager.shared.apiClient.performRequestWithBody(binkNetworkRequest, body: model, expecting: Safe<PaymentAccountResponseModel>.self) { (result, rawResponse) in
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
    
    func addLoyaltyCardTrusted(withRequestModel model: LoyaltyCardAddTrustedRequestModel, completion: @escaping ServiceCompletionResultRawResponseHandler<LoyaltyCardTrustedResponseModel, WalletServiceError>) {
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .loyaltyCardAddTrusted, method: .post, headers: nil)
        BinkPaymentsManager.shared.apiClient.performRequestWithBody(binkNetworkRequest, body: model, expecting: Safe<LoyaltyCardTrustedResponseModel>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    completion(.failure(.customError("Failed to decode response for added loyalty card")), rawResponse)
                    return
                }
                completion(.success(safeResponse), rawResponse)
            case .failure:
                completion(.failure(.failedToAddLoyaltyTrusted), rawResponse)
            }
        }
    }
    
    func updateLoyaltyCardTrusted(forLoyaltyCardId id: Int, model: LoyaltyCardUpdateTrustedRequestModel, completion: @escaping ServiceCompletionResultRawResponseHandler<LoyaltyCardTrustedResponseModel, WalletServiceError>) {
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .loyaltyCardUpdateTrusted(id: String(id)), method: .put, headers: nil)
        BinkPaymentsManager.shared.apiClient.performRequestWithBody(binkNetworkRequest, body: model, expecting: Safe<LoyaltyCardTrustedResponseModel>.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    completion(.failure(.customError("Failed to decode response for updated loyalty card")), rawResponse)
                    return
                }
                completion(.success(safeResponse), rawResponse)
            case .failure:
                completion(.failure(.failedToUpdateLoyaltyTrusted), rawResponse)
            }
        }
    }
    
    func getWalletFromAPI(completion: @escaping ServiceCompletionResultHandler<WalletModel, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .wallet, method: .get)
        BinkPaymentsManager.shared.apiClient.performRequest(request, expecting: Safe<WalletModel>.self) { result, rawResponse in
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
    
    func deleteLoyaltyCard(id: String, completion: ServiceCompletionSuccessHandler<NetworkingError>? = nil) {
        let request = BinkNetworkRequest(endpoint: .loyaltyCards(id: id), method: .delete)
        BinkPaymentsManager.shared.apiClient.performRequestWithNoResponse(request, body: nil) { success, _, _ in
            guard success else {
                completion?(false, nil)
                return
            }
            
            completion?(true, nil)
        }
    }
}
