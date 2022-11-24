//
//  NetworkingError.swift
//  
//
//  Created by Sean Williams on 24/11/2022.
//

import Foundation

enum NetworkingError: Error {
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
        }
    }
}
