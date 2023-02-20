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
    private let successStatusRange = 200...299
    private let noResponseStatus = 204
    private let clientErrorStatusRange = 400...499
    private let badRequestStatus = 400
    private let unauthorizedStatus = 401
    private let serverErrorStatusRange = 500...599
    
    private var networkIsReachable: Bool {
        return networkReachabilityManager?.isReachable ?? false
    }
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        session = Session(configuration: configuration)
    }
    
    func performRequest<ResponseType: Decodable>(_ request: BinkNetworkRequest, expecting responseType: ResponseType.Type, completion: APIClientCompletionHandler<ResponseType>?) {
        validateRequest(request) { [weak self] (validatedRequest, error) in
            if let error = error {
                completion?(.failure(error), nil)
                return
            }
            guard let validatedRequest = validatedRequest else {
                completion?(.failure(.invalidRequest), nil)
                return
            }
            session.request(validatedRequest.requestUrl, method: request.method, headers: validatedRequest.headers, interceptor: self).validate().cacheResponse(using: ResponseCacher.doNotCache).response { [weak self] response in
                self?.handleResponse(response, endpoint: request.endpoint, expecting: responseType, completion: completion)
            }
        }
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
            session.request(validatedRequest.requestUrl, method: request.method, parameters: body, encoder: JSONParameterEncoder.default, headers: validatedRequest.headers, interceptor: self).validate().cacheResponse(using: ResponseCacher.doNotCache).response { [weak self] response in
                self?.handleResponse(response, endpoint: request.endpoint, expecting: responseType, completion: completion)
            }
        }
    }
    
    private func validateRequest(_ request: BinkNetworkRequest, completion: (ValidatedNetworkRequest?, NetworkingError?) -> Void) {
        if !networkIsReachable {
            completion(nil, .noInternetConnection)
        }
   
        guard let url = request.endpoint.urlString else {
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
    var headers: [BinkHTTPHeader]?
}

struct ValidatedNetworkRequest {
    var requestUrl: String
    var headers: HTTPHeaders
}

struct ResponseErrors: Decodable {
    var nonFieldErrors: [String]?

    enum CodingKeys: String, CodingKey {
        case nonFieldErrors = "non_field_errors"
    }
}

private extension APIClient {
    func handleResponse<ResponseType: Decodable>(_ response: AFDataResponse<Data?>, endpoint: APIEndpoint, expecting responseType: ResponseType.Type, completion: APIClientCompletionHandler<ResponseType>?) {
        var networkResponseData = NetworkResponseData(urlResponse: response.response, errorMessage: nil)
        
        let apiResponseDict: [String: String] = [
            "statusCode": String(response.response?.statusCode ?? 0),
            "endpoint": endpoint.urlString ?? ""
        ]
        
        NotificationCenter.default.post(name: .apiResponse, object: nil, userInfo: apiResponseDict)
        
        if case let .failure(error) = response.result {
            completion?(.failure(.customError(error.localizedDescription)), networkResponseData)
            return
        }
        
        if let error = response.error {
            completion?(.failure(.customError(error.localizedDescription)), networkResponseData)
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        do {
            guard let statusCode = response.response?.statusCode else {
                completion?(.failure(.invalidResponse), networkResponseData)
                return
            }

            guard let data = response.data else {
                completion?(.failure(.invalidResponse), networkResponseData)
                return
            }
            
            do {
                let _ = try decoder.decode(responseType, from: data)
            } catch {
                print(String(describing: error))
            }
            
            if statusCode == unauthorizedStatus {
                // Unauthorized response
                completion?(.failure(.unauthorized), networkResponseData)
                return
            } else if successStatusRange.contains(statusCode) {
                // Successful response
                let decodedResponse = try decoder.decode(responseType, from: data)
                completion?(.success(decodedResponse), networkResponseData)
                return
            } else if clientErrorStatusRange.contains(statusCode) {
                // Failed response, client error
                if statusCode == badRequestStatus {
                    let decodedResponseErrors = try? decoder.decode(ResponseErrors.self, from: data)
                    let errorsArray = try? decoder.decode([String].self, from: data)
                    let errorsDictionary = try? decoder.decode([String: String].self, from: data)
                    let errorMessage = decodedResponseErrors?.nonFieldErrors?.first ?? errorsDictionary?.values.first ?? errorsArray?.first
                    networkResponseData.errorMessage = errorMessage

                    completion?(.failure(.customError(errorMessage ?? "Something went wrong")), networkResponseData)
                    return
                }
                completion?(.failure(.clientError(statusCode)), networkResponseData)
                return
            } else if serverErrorStatusRange.contains(statusCode) {
                // Failed response, server error
                completion?(.failure(.serverError(statusCode)), networkResponseData)
                return
            } else {
                completion?(.failure(.checkStatusCode(statusCode)), networkResponseData)
                return
            }
        } catch {
            completion?(.failure(.decodingError), networkResponseData)
        }
    }
}

extension APIClient: RequestInterceptor, AuthenticationService {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest

        guard urlRequest.url?.absoluteString.hasPrefix("https://core.spreedly.com") == false else {
            /// spreedly does not require auth
            return completion(.success(urlRequest))
        }

        guard urlRequest.url?.absoluteString.contains("token") == false else {
            urlRequest.setValue("bearer " + BinkPaymentsManager.shared.refreshToken, forHTTPHeaderField: "Authorization")
            return completion(.success(urlRequest))
        }

        /// default auth header
        urlRequest.setValue("bearer " + BinkPaymentsManager.shared.token, forHTTPHeaderField: "Authorization")

        completion(.success(urlRequest))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, (response.statusCode == 401) else {
            /// was not 401 so bail out
            return completion(.doNotRetryWithError(error))
        }
        
        requestToken(refresh: true) { result in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    completion(.doNotRetry)
                    return
                }
                BinkPaymentsManager.shared.token = safeResponse.accessToken
                try? TokenKeychainManager.saveToken(service: .accessTokenService, token: BinkPaymentsManager.shared.token)
                
                BinkPaymentsManager.shared.refreshToken = safeResponse.refreshToken
                try? TokenKeychainManager.saveToken(service: .refreshTokenService, token: BinkPaymentsManager.shared.refreshToken)
                
                completion(.retry)
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
        
        

        let model = RenewTokenRequestModel(grantType: "refresh_token", scope: ["user"])
        let binkRequest = BinkNetworkRequest(endpoint: .token, method: .post, headers: [.defaultContentType])
        self.performRequestWithBody(binkRequest, body: model, expecting: Safe<RenewTokenResponse>.self) { (result, _) in
            switch result {
            case .success(let response):
                guard let safeResponse = response.value else {
                    completion(.doNotRetry)
                    return
                }
                BinkPaymentsManager.shared.token = safeResponse.accessToken
                try? TokenKeychainManager.saveToken(service: .accessTokenService, token: BinkPaymentsManager.shared.token)
                
                BinkPaymentsManager.shared.refreshToken = safeResponse.refreshToken
                try? TokenKeychainManager.saveToken(service: .refreshTokenService, token: BinkPaymentsManager.shared.refreshToken)
                
                completion(.retry)
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
