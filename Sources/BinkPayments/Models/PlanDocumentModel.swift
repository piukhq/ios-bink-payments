//
//  PlanDocumentModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

public struct PlanDocumentModel: Codable {
    public let name: String?
    public let url: String?
    public let isAcceptanceRequired: Bool?
    public let order: Int?
    public let planDocumentDescription: String?

    enum CodingKeys: String, CodingKey {
        case name, url
        case isAcceptanceRequired = "is_acceptance_required"
        case order
        case planDocumentDescription = "description"
    }
}
