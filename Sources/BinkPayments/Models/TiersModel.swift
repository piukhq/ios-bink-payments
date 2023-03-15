//
//  TiersModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

/// Struct that holds information about the plan membership level
public struct TierModel: Codable {
    /// Name of the tier
    public let name: String?
    
    /// Explanation of what the tier provides.
    public let description: String?
}
