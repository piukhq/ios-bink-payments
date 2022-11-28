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

struct ResponseErrors: Decodable {
    var nonFieldErrors: [String]?

    enum CodingKeys: String, CodingKey {
        case nonFieldErrors = "non_field_errors"
    }
}

private extension APIClient {
    func handleResponse<ResponseType: Decodable>(_ response: AFDataResponse<Data?>, endpoint: APIEndpoint, expecting responseType: ResponseType.Type, isUserDriven: Bool, completion: APIClientCompletionHandler<ResponseType>?) {
        var networkResponseData = NetworkResponseData(urlResponse: response.response, errorMessage: nil)
        
        if case let .failure(error) = response.result, error.isServerTrustEvaluationError, isUserDriven {
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
                // TODO: Can we remove this and just respond to the error sent back in completion by either showing the error message or not?
//                NotificationCenter.default.post(name: isUserDriven ? .outageError : .outageSilentFail, object: nil)
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
