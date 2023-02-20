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


class WalletService {
    private let apiClient = APIClient()

    func getLoyaltyPlan(for Id: String, completion: @escaping ServiceCompletionResultHandler<LoyaltyPlanModel?, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .plan(Id: Id), method: .get, headers: nil)
        apiClient.performRequest(request, expecting: Safe<LoyaltyPlanModel>.self) { (result, rawResponse) in
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
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .createPaymentAccount, method: .post, headers: nil)
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
    
    func addLoyaltyCardTrusted(withRequestModel model: LoyaltyCardAddTrustedRequestModel, completion: @escaping ServiceCompletionResultRawResponseHandler<LoyaltyCardTrustedResponseModel, WalletServiceError>) {
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .loyaltyCardAddTrusted, method: .post, headers: nil)
        apiClient.performRequestWithBody(binkNetworkRequest, body: model, expecting: Safe<LoyaltyCardTrustedResponseModel>.self) { (result, rawResponse) in
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
        apiClient.performRequestWithBody(binkNetworkRequest, body: model, expecting: Safe<LoyaltyCardTrustedResponseModel>.self) { (result, rawResponse) in
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

protocol AuthenticationService {
    func requestToken(refresh: Bool, completion: @escaping (Result<Safe<RenewTokenResponse>, NetworkingError>) -> Void)
}

extension AuthenticationService {
    func requestToken(refresh: Bool = false, completion: @escaping (Result<Safe<RenewTokenResponse>, NetworkingError>) -> Void) {
        let model = RenewTokenRequestModel(grantType: refresh ? "refresh_token" : "b2b", scope: ["user"])
        let binkRequest = BinkNetworkRequest(endpoint: .token, method: .post, headers: [.defaultContentType])
        APIClient().performRequestWithBody(binkRequest, body: model, expecting: Safe<RenewTokenResponse>.self) { (result, rawResponse) in
            completion(result)
        }
    }
}
