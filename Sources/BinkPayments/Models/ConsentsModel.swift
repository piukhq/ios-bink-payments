//
//  ConsentsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

public struct ConsentsModel: Codable {
    public let consentSlug: String?
    public let isAcceptanceRequired: Bool?
    public let order: Int?
    public let entDescription, name: String?
    public let url: String?

    enum CodingKeys: String, CodingKey {
        case consentSlug = "consent_slug"
        case isAcceptanceRequired = "is_acceptance_required"
        case order
        case entDescription = "description"
        case name, url
    }
}
