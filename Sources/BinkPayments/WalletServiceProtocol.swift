//
//  WalletServiceProtocol.swift
//  
//
//  Created by Sean Williams on 30/11/2022.
//

import Foundation

class WalletService {
    private let apiClient = APIClient()

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
    
    func addPaymentCard(withRequestModel model: PaymentCardCreateRequest, completion: @escaping (Result<PaymentCardResponseModel, WalletServiceError>, NetworkResponseData?) -> Void) {
        let binkNetworkRequest = BinkNetworkRequest(endpoint: .createPaymentAccount, method: .post, headers: nil, isUserDriven: true)
        apiClient.performRequestWithBody(binkNetworkRequest, body: model, expecting: Safe<PaymentCardResponseModel>.self) { (result, rawResponse) in
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
    
//    func getWalletFromAPI(isUserDriven: Bool, completion: @escaping ServiceCompletionResultHandler<WalletModel, WalletServiceError>) {
//        let request = BinkNetworkRequest(endpoint: .wallet, method: .get, isUserDriven: false)
//        apiClient.performRequest(request, expecting: Safe<WalletModel>.self) { result, rawResponse in
//            switch result {
//            case .success(let response):
//                guard let safeResponse = response.value else {
//                    completion(.failure(.failedToDecodeWallet))
//                    return
//                }
//                completion(.success(safeResponse))
//            case .failure(let error):
//                print(error.localizedDescription)
//                completion(.failure(.failedToGetWallet))
//            }
//        }
//    }
}

enum WalletServiceError: Error {
    case failedToGetSpreedlyToken
    case failedToAddPaymentCard
    case failedToDecodeWallet
    case failedToGetWallet
    case failedToGetLoyaltyPlans(NetworkingError)
    case customError(String)
    
    var message: String {
        switch self {
        case .failedToGetSpreedlyToken:
            return "Failed to get Spreedly token"
        case .failedToAddPaymentCard:
            return "Failed to add payment account"
        case .failedToDecodeWallet:
            return "Failed to decode wallet"
        case .failedToGetWallet:
            return "Failed to get wallet"
        case .customError(let message):
            return message
        case .failedToGetLoyaltyPlans:
            return "Failed to get loyalty plans"
        }
    }
}
