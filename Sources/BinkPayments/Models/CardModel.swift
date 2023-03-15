//
//  CardModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

/// Struct that contains basic info about a loyalty card
public struct CardModel: Codable {
    /// Resource Id
    public let apiId: Int?
    
    /// Barcode value for this Loyalty Card.
    public let barcode: String?
    
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
    
    /// Loyalty membership number.
    public let cardNumber: String?
    
    /// Brand approved background colour - hex format.
    public let colour: String?
    
    /// Brand approved text colour - hex format.
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
