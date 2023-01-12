//
//  String+Extension.swift
//  
//
//  Created by Sean Williams on 23/11/2022.
//

import Foundation
import CommonCrypto

extension String {
    var sha256: String {
        return HMAC.hash(inp: self, algo: HMACAlgo.SHA256)
    }

    public enum HMAC {
        static func hash(inp: String, algo: HMACAlgo) -> String {
            guard let stringData = inp.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                fatalError("Failed to hash")
            }
            return hexStringFromData(input: digest(input: stringData as NSData, algo: algo))
        }
        
        private static func digest(input: NSData, algo: HMACAlgo) -> NSData {
            let digestLength = algo.digestLength()
            var hash = [UInt8](repeating: 0, count: digestLength)
            switch algo {
            case .SHA1:
                CC_SHA1(input.bytes, UInt32(input.length), &hash)
            case .SHA224:
                CC_SHA224(input.bytes, UInt32(input.length), &hash)
            case .SHA256:
                CC_SHA256(input.bytes, UInt32(input.length), &hash)
            case .SHA384:
                CC_SHA384(input.bytes, UInt32(input.length), &hash)
            case .SHA512:
                CC_SHA512(input.bytes, UInt32(input.length), &hash)
            }
            return NSData(bytes: hash, length: digestLength)
        }
        
        private static func hexStringFromData(input: NSData) -> String {
            var bytes = [UInt8](repeating: 0, count: input.length)
            input.getBytes(&bytes, length: input.length)
            
            var hexString = ""
            for byte in bytes {
                hexString += String(format: "%02x", UInt8(byte))
            }
            
            return hexString
        }
    }
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in
            return letters.randomElement()!
        })
    }
}

enum HMACAlgo {
case SHA1, SHA224, SHA256, SHA384, SHA512

    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
