//
//  FieldsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

public struct FieldsModel: Codable {
    /// Personal information required to complete the selected journey.
    public let credentials: [CredentialsModel]?
    
    /// Legal copy to be displayed and sometimes accepted by the user.
    public let planDocuments: [PlanDocumentModel]?
    
    /// Brand marketing information to be displayed and sometimes accepted by the user.
    public let consents: [ConsentsModel]?

    enum CodingKeys: String, CodingKey {
        case credentials
        case planDocuments = "plan_documents"
        case consents
    }
}
