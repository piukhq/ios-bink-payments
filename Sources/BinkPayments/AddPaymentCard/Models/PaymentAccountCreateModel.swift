//
//  PaymentCardCreateModel.swift
//  
//
//  Created by Sean Williams on 20/10/2022.
//

import Foundation

/// Model with the basic information related to a payment card
public class PaymentAccountCreateModel: Codable {
    public var fullPan: String?
    var nameOnCard: String?
    var month: Int?
    var year: Int?
    var cardType: PaymentCardType?
    var uuid = UUID().uuidString
    var cardNickname: String?
    
    public init(fullPan: String?, nameOnCard: String?, month: Int?, year: Int?, cardNickname: String?) {
        self.fullPan = fullPan
        self.nameOnCard = nameOnCard
        self.month = month
        self.year = year
        self.cardNickname = cardNickname
        
        if let fullPan = fullPan {
            setType(with: fullPan)
            formattFullPanIfNecessary()
        }
    }
    
    func setType(with pan: String) {
        self.cardType = PaymentCardType.type(from: pan)
    }
    
    public func formattedExpiryDate() -> String? {
        guard let month = month, let year = year else { return nil }
        return "\(month)/\(year)"
    }
    
    private func formattFullPanIfNecessary() {
        /// If we have scanned a card, we will have a fullPan available
        /// This pan should not contain any spaces, but guard against it anyway
        if fullPan?.contains(" ") == false {
            /// Using the indexes given a card type, insert a whitespace character at each index in the array
            if var formattedFullPan = fullPan, let whitespaceIndexes = cardType?.lengthRange().whitespaceIndexes {
                whitespaceIndexes.forEach { index in
                    formattedFullPan.insert(" ", at: formattedFullPan.index(formattedFullPan.startIndex, offsetBy: index))
                }
                
                /// Set the full pan to our newly formatted pan which includes whitespace
                fullPan = formattedFullPan
            }
        }
    }
}
