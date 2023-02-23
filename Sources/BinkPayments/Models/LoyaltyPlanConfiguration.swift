//
//  Configuration.swift
//  
//
//  Created by Sean Williams on 17/01/2023.
//

import Foundation

public struct LoyaltyPlanConfiguration {
    public enum TrustedCredentialType: String {
        case add
        case authorise
    }
    
    public init(testLoyaltyPlanID: String, productionLoyaltyPlanID: String, trustedCredentialType: TrustedCredentialType) {
        self.testLoyaltyPlanID = testLoyaltyPlanID
        self.productionLoyaltyPlanID = productionLoyaltyPlanID
        self.trustedCredentialType = trustedCredentialType
    }
    
    var testLoyaltyPlanID: String
    var productionLoyaltyPlanID: String
    var trustedCredentialType: TrustedCredentialType
}
