//
//  PlanDocumentModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

struct PlanDocumentModel: Codable {
    let name: String?
    let url: String?
    let isAcceptanceRequired: Bool?
    let order: Int?
    let planDocumentDescription: String?

    enum CodingKeys: String, CodingKey {
        case name, url
        case isAcceptanceRequired = "is_acceptance_required"
        case order
        case planDocumentDescription = "description"
    }
}
