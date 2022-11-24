//
//  APIClient.swift
//  
//
//  Created by Sean Williams on 23/11/2022.
//

import Alamofire
import Foundation

class APIClient {
    private let session: Session
    private let networkReachabilityManager = NetworkReachabilityManager()
    
    private var networkIsReachable: Bool {
        return networkReachabilityManager?.isReachable ?? false
    }
    
    init() {
        let url = "EnvironmentType.production.rawValue"

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        
        session = Session(configuration: configuration)
    }
    
    func performRequestWithBody<ResponseType: Decodable, P: Encodable>(_ request: BinkNetworkRequest, body: P?, expecting responseType: ResponseType.Type, completion: APIClientCompletionHandler<ResponseType>?) {
        validateRequest(request) { (validatedRequest, error) in
            if let error = error {
                completion?(.failure(error), nil)
                return
            }
            guard let validatedRequest = validatedRequest else {
                completion?(.failure(.invalidRequest), nil)
                return
            }
            session.request(validatedRequest.requestUrl, method: request.method, parameters: body, encoder: JSONParameterEncoder.default, headers: validatedRequest.headers).cacheResponse(using: ResponseCacher.doNotCache).response { [weak self] response in
                self?.handleResponse(response, endpoint: request.endpoint, expecting: responseType, isUserDriven: request.isUserDriven, completion: completion)
            }
        }
    }
    
    private func validateRequest(_ request: BinkNetworkRequest, completion: (ValidatedNetworkRequest?, NetworkingError?) -> Void) {
        if !networkIsReachable && request.isUserDriven {
            completion(nil, .noInternetConnection)
        }
        
        var requestUrl: String?
        if let params = request.queryParameters {
            requestUrl = request.endpoint.urlString(withQueryParameters: params)
        } else {
            requestUrl = request.endpoint.urlString
        }
        guard let url = requestUrl else {
            completion(nil, .invalidUrl)
            return
        }
        
        guard request.endpoint.allowedMethods.contains(request.method) else {
            completion(nil, .methodNotAllowed)
            return
        }

        let requestHeaders = HTTPHeaders(BinkHTTPHeaders.asDictionary(request.headers ?? request.endpoint.headers))
        completion(ValidatedNetworkRequest(requestUrl: url, headers: requestHeaders), nil)
    }
}

typealias APIClientCompletionHandler<ResponseType: Any> = (Result<ResponseType, NetworkingError>, NetworkResponseData?) -> Void

struct NetworkResponseData {
    var urlResponse: HTTPURLResponse?
    var errorMessage: String?
}

struct BinkNetworkRequest {
    var endpoint: APIEndpoint
    var method: HTTPMethod
    var queryParameters: [String: String]?
    var headers: [BinkHTTPHeader]?
    var isUserDriven: Bool
}

struct ValidatedNetworkRequest {
    var requestUrl: String
    var headers: HTTPHeaders
}
