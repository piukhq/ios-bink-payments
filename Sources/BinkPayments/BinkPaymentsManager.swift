//
//  BinkPaymentsManager.swift
//  
//
//  Created by Ricardo Silva on 13/09/2022.
//

import Foundation

class BinkPaymentsManager {
    static let shared = BinkPaymentsManager()
    
    private var token: String!
    private var environmentKey: String!

    private init() {}
    
    func configure(token: String!, environmentKey: String!) {
        assert(!token.isEmpty && !environmentKey.isEmpty, "Bink Payments SDK Error - Not Initialised due to missing token/environment key")
        
        self.token = token
        self.environmentKey = environmentKey
        print("Bink Payments SDK Initialised")
    }
}

