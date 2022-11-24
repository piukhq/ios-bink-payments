//
//  Created by Sean Williams on 23/11/2022.
//
//  BinkHTTPHeaders.swift
//


import UIKit

enum BinkHTTPHeaders {
    static func asDictionary(_ headers: [BinkHTTPHeader]) -> [String: String] {
        var dictionary: [String: String] = [:]
        headers.forEach {
            dictionary[$0.name] = $0.value
        }
        return dictionary
    }
}

struct BinkHTTPHeader {
    let name: String
    let value: String
    
    // MARK: - Headers

    static func userAgent(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "User-Agent", value: value)
    }
    
    static func contentType(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Content-Type", value: value)
    }
    
    static func accept(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Accept", value: value)
    }
    
    static func authorization(_ value: String) -> BinkHTTPHeader {
        return BinkHTTPHeader(name: "Authorization", value: "bearer \(value)")
    }
    
    // MARK: - Defaults

    static let defaultUserAgent: BinkHTTPHeader = {
        return userAgent("Bink SDK / iOS / \(UIDevice.current.systemVersion)")
    }()
    
    static let defaultContentType: BinkHTTPHeader = {
        return contentType("application/json")
    }()
    
    static let defaultAccept: BinkHTTPHeader = {
        return accept("application/json")
    }()
}
