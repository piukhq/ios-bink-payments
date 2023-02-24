//
//  CredentialsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

/// Different fields related to credentials
public class CredentialsModel: Codable {
    /// Specifies the order in which to display this field. The order is unique within the entire list of fields that need to be displayed to support the chosen journey. The field list can be made up of Credentials, Plan Documents and Consents.
    public let order: Int?
    
    /// Text label used in the UI to identify the required information.
    public let displayLabel: String?
    
    /// Regular expression to validate input value.
    public let validation: String?
    
    /// Text field that can be used as a hint to the user, guiding them on input.
    public let credentialDescription: String?
    
    /// A common name which can be used in mapping or prepopulating data.
    public let credentialSlug: String?
    
    /// Supported field types are: text, sensitive, choice, boolean
    public let type: String?
    
    /// Indicates whether or not this field is sensitive and therefore requires special UI controls. For example a Password field.
    public let isSensitive: Bool?
    
    /// A list of possible values to be presented to the user when the type = choice.
    public let choice: [String]?
    
    /// Will display the same keys as the primary credential but with alternative values. E.g. card_number as an alternative to barcode.
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
