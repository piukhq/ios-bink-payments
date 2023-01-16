//
//  FieldsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

struct FieldsModel: Codable {
    let credentials: [CredentialsModel]?
    let planDocuments: [PlanDocumentModel]?
    let consents: [ConsentsModel]?

    enum CodingKeys: String, CodingKey {
        case credentials
        case planDocuments = "plan_documents"
        case consents
    }
}
