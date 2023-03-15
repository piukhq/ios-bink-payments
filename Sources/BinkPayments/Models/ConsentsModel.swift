//
//  ConsentsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

/// Information regarding the user's consents.
public struct ConsentsModel: Codable {
    public let consentSlug: String?
    
    /// Indicates whether or not the user must accept this Consent.
    public let isAcceptanceRequired: Bool?
    
    /// Specifies the order in which to display this field. The order is unique within the entire list of fields that need to be displayed to support the chosen journey. The field list can be made up of Credentials, Plan Documents and Consents.
    public let order: Int?
    
    /// Describes how to use the Consent.
    public let entDescription: String?
    
    /// Consent name.
    public let name: String?
    
    /// Consent URL
    public let url: String?

    enum CodingKeys: String, CodingKey {
        case consentSlug = "consent_slug"
        case isAcceptanceRequired = "is_acceptance_required"
        case order
        case entDescription = "description"
        case name, url
    }
}
