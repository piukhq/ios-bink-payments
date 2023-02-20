//
//  File.swift
//  
//
//  Created by Ricardo Silva on 20/01/2023.
//

import Foundation

enum KeychainService: String {
    case accessTokenService = "accessTokenService"
    case refreshTokenService = "refreshTokenService"
    case account = "com.bink.sdk"
}

class TokenKeychainManager {
    enum KeychainError: Error {
        case badData
        case unknown(OSStatus)
    }
    
    static func saveToken(service: KeychainService, token: String) throws {
        guard let tokenData = token.data(using: .utf8) else {
            throw KeychainError.badData
        }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeychainService.account.rawValue,
            kSecAttrService as String: service.rawValue
        ]
        
        /// Can't insert dupes so we remove before inserting
        let deleteStatus = SecItemDelete(query as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else {
            throw KeychainError.unknown(deleteStatus)
        }
        
        /// add the item with the data
        query[kSecValueData as String] = tokenData
        
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainError.unknown(addStatus)
        }
    }
    
    static func getToken(service: KeychainService) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeychainService.account.rawValue,
            kSecAttrService as String: service.rawValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard let existingItem = item as? [String: Any],
              let valueData = existingItem[kSecValueData as String] as? Data,
              let value = String(data: valueData, encoding: .utf8)
        else {
            return nil
        }

        return value
    }
}