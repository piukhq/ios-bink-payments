//
//  CardModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

public struct CardModel: Codable {
    public let apiId: Int?
    public let barcode: String?
    public let barcodeType: Int?
    public let cardNumber, colour: String?
    public let textColour: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case barcode
        case barcodeType = "barcode_type"
        case cardNumber = "card_number"
        case textColour = "text_colour"
        case colour
    }
}
