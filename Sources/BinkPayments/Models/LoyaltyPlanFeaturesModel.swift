//
//  PlanFeaturesModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

/// Struct containing the Loyalty Plan properties
public struct LoyaltyPlanFeaturesModel: Codable {
    /// Identifies that the Loyalty Plan supports showing a balance.
    public let hasPoints: Bool?
    
    /// Specifies if this plan supports display of transaction history.
    public let hasTransactions: Bool?
    
    /// 0 - Store
    /// 1 - Engage
    /// 2 - PLL
    /// 3 - Coming soon
    public let planType: Int?
    
    /// 0 = Code128 (B or C),
    /// 1 = QR Code,
    /// 2 = AztecCode,
    /// 3 = Pdf417,
    /// 4 = EAN(13),
    /// 5 = Datamatrix,
    /// 6 = ITF(Interleaved 2 of 5),
    /// 7 = Code39,
    /// 9 = Barcode Not Supported
    public let barcodeType: Int?
    
    /// Brand approved background colour - hex format.
    public let colour: String?
    
    /// Types of journeys that this plan supports.
    public let journeys: [JourneyModel]?

    enum CodingKeys: String, CodingKey {
        case hasPoints = "has_points"
        case hasTransactions = "has_transactions"
        case planType = "plan_type"
        case barcodeType = "barcode_type"
        case colour, journeys
    }
}
