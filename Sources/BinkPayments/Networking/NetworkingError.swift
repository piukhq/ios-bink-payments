//
//  NetworkingError.swift
//  
//
//  Created by Sean Williams on 24/11/2022.
//

import Foundation

enum BinkErrorDomain: Int {
    case networking
    case walletService
}

protocol BinkError: Error {
    var domain: BinkErrorDomain { get }
    var message: String { get }
}

extension BinkError {
    var localizedDescription: String {
        return message
    }
}

enum NetworkingError: BinkError {
    case invalidRequest
    case unauthorized
    case noInternetConnection
    case methodNotAllowed
    case invalidUrl
    case invalidResponse
    case decodingError
    case clientError(Int)
    case serverError(Int)
    case checkStatusCode(Int)
    case customError(String)
    case failedToGetSpreedlyToken

    var domain: BinkErrorDomain {
        return .networking
    }
    
    var message: String {
        switch self {
        case .invalidRequest:
            return "Invalid request"
        case .unauthorized:
            return "Request unauthorized"
        case .noInternetConnection:
            return "No internet connection"
        case .methodNotAllowed:
            return "Method not allowed"
        case .invalidUrl:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .decodingError:
            return "Decoding error"
        case .clientError(let status):
            return "Client error with status code \(String(status))"
        case .serverError(let status):
            return "Server error with status code \(String(status))"
        case .checkStatusCode(let status):
            return "Error with status code \(String(status))"
        case .customError(let message):
            return message
        case .failedToGetSpreedlyToken:
            return "Failed to get Spreedly token"
        }
    }
}

enum WalletServiceError: BinkError {
    case failedToGetSpreedlyToken
    case failedToAddPaymentCard
    case failedToDecodeWallet
    case failedToGetWallet
    case failedToGetLoyaltyPlan(NetworkingError)
    case customError(String)
    case failedToRenewToken
    case failedToAddLoyaltyTrusted
    case failedToUpdateLoyaltyTrusted

    var domain: BinkErrorDomain {
        return .walletService
    }
    
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
        case .failedToRenewToken:
            return "Failed to renew token"
        case .failedToGetLoyaltyPlan:
            return "Failed to get loyalty plan"
        case .failedToAddLoyaltyTrusted:
            return "Failed to add loyalty card"
        case .failedToUpdateLoyaltyTrusted:
            return "Failed to update loyalty card"
        }
    }
}
