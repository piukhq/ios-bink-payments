//
//  PlanDetailsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import CoreData
import Foundation

public struct LoyaltyPlanDetailsModel: Codable {
    public let apiId: Int?
    public let companyName, planName, planLabel: String?
    public let planURL: String?
    public let planSummary, planDescription, redeemInstructions, planRegisterInfo: String?
    public let joinIncentive, category: String?
    public let tiers: [TierModel]?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case companyName = "company_name"
        case planName = "plan_name"
        case planLabel = "plan_label"
        case planURL = "plan_url"
        case planSummary = "plan_summary"
        case planDescription = "plan_description"
        case redeemInstructions = "redeem_instructions"
        case planRegisterInfo = "plan_register_info"
        case joinIncentive = "join_incentive"
        case category, tiers
    }
}
