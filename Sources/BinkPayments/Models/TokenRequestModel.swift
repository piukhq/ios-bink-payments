//
//  File.swift
//  
//
//  Created by Ricardo Silva on 19/01/2023.
//

import Foundation

struct RenewTokenResponse: Codable {
    let accessToken: String?
    let tokenType: String?
    let expiresIn: Int?
    let refreshToken: String?
    let scope: [String]?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

struct RenewTokenRequestModel: Codable {
    let grantType: String?
    let scope: [String]?
    
    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case scope
    }
}
