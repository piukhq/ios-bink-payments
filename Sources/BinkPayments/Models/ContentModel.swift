//
//  ContentModel.swift
//  LocalHero
//
//  Created by Sean Williams on 28/02/2022.
//

import Foundation

/// Key value pairs that can be used to support UI elements. Property in ``LoyaltyPlanModel/content``
public struct ContentModel: Codable {
    public let column: String?
    public let value: String?
}
