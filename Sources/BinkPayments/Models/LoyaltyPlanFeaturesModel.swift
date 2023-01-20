//
//  PlanFeaturesModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

public struct LoyaltyPlanFeaturesModel: Codable {
    public let hasPoints, hasTransactions: Bool?
    public let planType, barcodeType: Int?
    public let colour: String?
    public let journeys: [JourneyModel]?

    enum CodingKeys: String, CodingKey {
        case hasPoints = "has_points"
        case hasTransactions = "has_transactions"
        case planType = "plan_type"
        case barcodeType = "barcode_type"
        case colour, journeys
    }
}
