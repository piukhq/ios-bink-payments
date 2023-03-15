//
//  PlanDocumentModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

/// Document base
public struct PlanDocumentModel: Codable {
    /// The reference name of the Document.
    public let name: String?
    
    /// Link to the Document contents.
    public let url: String?
    
    /// Indicates whether or not the user must accept this Document before being allowed to proceed with the journey.
    public let isAcceptanceRequired: Bool?
    
    /// Specifies the order in which to display this field. The order is unique within the entire list of fields that need to be displayed to support the chosen journey. The field list can be made up of Credentials, Plan Documents and Consents.
    public let order: Int?
    
    /// Describes how to use the Plan Document.
    public let planDocumentDescription: String?

    enum CodingKeys: String, CodingKey {
        case name, url
        case isAcceptanceRequired = "is_acceptance_required"
        case order
        case planDocumentDescription = "description"
    }
}
