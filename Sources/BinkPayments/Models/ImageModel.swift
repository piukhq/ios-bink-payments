//
//  ImageModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import CoreData
import Foundation

struct ImageModel: Codable {
    let apiId: Int?
    let type: Int?
    let url: String?
    let imageDescription: String?
    let encoding: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case type, url
        case imageDescription = "description"
        case encoding
    }
}
