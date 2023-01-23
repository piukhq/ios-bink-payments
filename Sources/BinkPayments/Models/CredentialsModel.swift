//
//  CredentialsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

public class CredentialsModel: Codable {
    public let order: Int?
    public let displayLabel: String?
    public let validation: String?
    public let credentialDescription, credentialSlug: String?
    public let type: String?
    public let isSensitive: Bool?
    public let choice: [String]?
    public let alternative: CredentialsModel?
    public var value: String?

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
