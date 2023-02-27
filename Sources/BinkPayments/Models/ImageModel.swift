//
//  ImageModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import CoreData
import Foundation

/// Struct that defines an image associated with a ``LoyaltyPlanModel``
public struct ImageModel: Codable {
    public let apiId: Int?
    public let type: Int?
    public let url: String?
    public let imageDescription: String?
    public let encoding: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case type, url
        case imageDescription = "description"
        case encoding
    }
}
