//
//  PlanDetailsModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import CoreData
import Foundation

public struct LoyaltyPlanDetailsModel: Codable {
    /// Resource Id
    public let apiId: Int?
    
    ///The name of the Loyalty provider.
    public let companyName: String?
    
    /// The brand name of the Loyalty Plan.
    public let planName: String?
    
    /// The merchant’s name for the instrument when describing the plan itself
    public let planLabel: String?
    
    /// Url for the Loyalty Plan.
    public let planURL: String?
    
    /// Short form description for this Loyalty Plan.
    public let planSummary: String?
    
    /// Full description for this Loyalty Plan.
    public let planDescription: String?
    
    /// Explanation of how to redeem rewards or spend accrued Loyalty balances.
    public let redeemInstructions: String?
    
    /// Instructions for unregistered Loyalty Cards.
    public let planRegisterInfo: String?
    
    /// Describes any incentives for Joining the Loyalty Plan. E.g. Get 100 points as a new member!
    public let joinIncentive: String?
    
    /// Market sector or retail category.
    public let category: String?
    
    /// This is used for plans that have multiple membership levels
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
