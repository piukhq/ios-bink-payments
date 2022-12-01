//
//  CardModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

struct CardModel: Codable {
    let apiId: Int?
    let barcode: String?
    let barcodeType: Int?
    let cardNumber, colour: String?
    let textColour: String?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case barcode
        case barcodeType = "barcode_type"
        case cardNumber = "card_number"
        case textColour = "text_colour"
        case colour
    }
}
