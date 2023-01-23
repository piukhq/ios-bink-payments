//
//  FieldsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

public struct FieldsModel: Codable {
    public let credentials: [CredentialsModel]?
    public let planDocuments: [PlanDocumentModel]?
    public let consents: [ConsentsModel]?

    enum CodingKeys: String, CodingKey {
        case credentials
        case planDocuments = "plan_documents"
        case consents
    }
}
