//
//  StatusModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

enum MembershipCardStatus: String, Codable {
    case authorised
    case unauthorised
    case pending
    case failed
}

struct StatusModel: Codable {
    let apiId: Int?
    let state: MembershipCardStatus?
    let slug: String?
    let statusDescription: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case state, slug
        case statusDescription = "description"
    }
}
