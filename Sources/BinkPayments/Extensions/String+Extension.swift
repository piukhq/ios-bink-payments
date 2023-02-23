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
        return HMAC.hash(inp: self)
    }

    public enum HMAC {
        static func hash(inp: String) -> String {
            guard let stringData = inp.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
                fatalError("Failed to hash")
            }
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        
        private static func digest(input: NSData) -> NSData {
            let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
            var hash = [UInt8](repeating: 0, count: digestLength)
            CC_SHA256(input.bytes, UInt32(input.length), &hash)
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
