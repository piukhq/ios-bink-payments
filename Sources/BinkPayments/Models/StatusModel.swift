//
//  StatusModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

/// Valid statuses for a membership card
public enum MembershipCardStatus: String, Codable {
    case authorised
    case unauthorised
    case pending
    case failed
}

/// Status of a Loyalty Card in the wallet
public struct StatusModel: Codable {
    /// Resource Id
    public let apiId: Int?
    
    /// Card status
    public let state: MembershipCardStatus?
    
    /// If the Loyalty Card is in a state other than active, there will be a human-readable identifier that is easy to code against.
    public let slug: String?
    
    /// If the Loyalty Card is in a state other than active, there will be text to describe the state of the Card.
    public let statusDescription: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case state, slug
        case statusDescription = "description"
    }
}
