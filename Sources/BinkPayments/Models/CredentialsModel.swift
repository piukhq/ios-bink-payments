//
//  CredentialsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

class CredentialsModel: Codable {
    let order: Int?
    let displayLabel: String?
    let validation: String?
    let credentialDescription, credentialSlug: String?
    let type: String?
    let isSensitive: Bool?
    let choice: [String]?
    let alternative: CredentialsModel?
    var value: String?

    enum CodingKeys: String, CodingKey {
        case order
        case displayLabel = "display_label"
        case validation
        case credentialDescription = "description"
        case credentialSlug = "credential_slug"
        case type
        case isSensitive = "is_sensitive"
        case choice, alternative
    }

    init(order: Int?, displayLabel: String?, validation: String?, credentialDescription: String?, credentialSlug: String?, type: String?, isSensitive: Bool?, choice: [String]?, alternative: CredentialsModel?) {
        self.order = order
        self.displayLabel = displayLabel
        self.validation = validation
        self.credentialDescription = credentialDescription
        self.credentialSlug = credentialSlug
        self.type = type
        self.isSensitive = isSensitive
        self.choice = choice
        self.alternative = alternative
    }
}
