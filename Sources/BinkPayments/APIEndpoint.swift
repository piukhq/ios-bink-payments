//
//  APIEndpoint.swift
//  
//
//  Created by Sean Williams on 23/11/2022.

import Alamofire
import Foundation

enum APIEndpoint {
    case token
    case createPaymentAccount
    case spreedly
    case wallet
    case plan(Id: String)
    case loyaltyCardAddTrusted
    case loyaltyCardUpdateTrusted(id: String)
    
    var headers: [BinkHTTPHeader] {
        var headers: [BinkHTTPHeader] = [.defaultUserAgent, .defaultContentType]
        headers.append(.defaultAccept)
        
        if authRequired {
            guard let token = BinkPaymentsManager.shared.token else { return headers }
            headers.append(.authorization(token))
        }
        
        return headers
    }

    var urlString: String? {
        guard usesComponents else {
            return path
        }
        var components = URLComponents()
        components.scheme = scheme
        components.host = baseURLString
        components.path = path
        return components.url?.absoluteString.removingPercentEncoding
    }

    var baseURLString: String {
        if BinkPaymentsManager.shared.isDebug {
            return "api.staging.gb.bink.com"
        } else {
            return "api.gb.bink.com"
        }
    }
    
    var allowedMethods: [HTTPMethod] {
        return [.get, .post, .put]
    }
    
    private var authRequired: Bool {
        switch self {
        case .spreedly:
            return false
        default: return true
        }
    }

    private var shouldVersionPin: Bool {
        switch self {
        case .spreedly:
            return false
        default: return true
        }
    }

    private var usesComponents: Bool {
        switch self {
        case .spreedly:
            return false
        default: return true
        }
    }

    private var scheme: String {
        return "https"
    }
    
    var path: String {
        switch self {
        case .token:
            return "/v2/token"
        case .createPaymentAccount:
            return "/v2/payment_accounts"
        case .spreedly:
            return "https://core.spreedly.com/v1/payment_methods?environment_key=\(BinkPaymentsManager.shared.environmentKey ?? "")"
        case .wallet:
            return "/v2/wallet"
        case .plan(let Id):
            return "/v2/loyalty_plans/\(Id)"
        case .loyaltyCardAddTrusted:
            return "/v2/loyalty_cards/add_trusted"
        case .loyaltyCardUpdateTrusted(let id):
            return "/v2/loyalty_cards/\(id)/add_trusted"
        }
    }
}
