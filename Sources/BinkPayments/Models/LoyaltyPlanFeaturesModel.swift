//
//  PlanFeaturesModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

struct LoyaltyPlanFeaturesModel: Codable {
    let hasPoints, hasTransactions: Bool?
    let planType, barcodeType: Int?
    let colour: String?
    let journeys: [JourneyModel]?

    enum CodingKeys: String, CodingKey {
        case hasPoints = "has_points"
        case hasTransactions = "has_transactions"
        case planType = "plan_type"
        case barcodeType = "barcode_type"
        case colour, journeys
    }
}
