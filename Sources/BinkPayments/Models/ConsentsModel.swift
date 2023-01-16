//
//  ConsentsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

struct ConsentsModel: Codable {
    let consentSlug: String?
    let isAcceptanceRequired: Bool?
    let order: Int?
    let entDescription, name: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case consentSlug = "consent_slug"
        case isAcceptanceRequired = "is_acceptance_required"
        case order
        case entDescription = "description"
        case name, url
    }
}
