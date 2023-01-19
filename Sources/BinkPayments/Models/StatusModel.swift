//
//  StatusModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

public enum MembershipCardStatus: String, Codable {
    case authorised
    case unauthorised
    case pending
    case failed
}

public struct StatusModel: Codable {
    public let apiId: Int?
    public let state: MembershipCardStatus?
    public let slug: String?
    public let statusDescription: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case state, slug
        case statusDescription = "description"
    }
}
