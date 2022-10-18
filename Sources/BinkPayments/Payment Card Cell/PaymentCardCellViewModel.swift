//
//  PaymentCardCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 25/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct PaymentCardCellViewModel {
    private let paymentCard: PaymentCardCreateModel

    init(paymentCard: PaymentCardCreateModel) {
        self.paymentCard = paymentCard
    }

    var nameOnCardText: String? {
        return paymentCard.nameOnCard
    }

    var cardNumberText: NSAttributedString? {
        return cardNumberAttributedString()
    }

    var paymentCardType: PaymentCardType? {
        return PaymentCardType.type(from: paymentCard.fullPan)
    }

    var isExpired: Bool {
        guard let expiryYear = paymentCard.year, let expiryMonth = paymentCard.month else { return false }
        guard let expiryDate = Date.makeDate(year: expiryYear, month: expiryMonth, day: 01, hr: 12, min: 00, sec: 00) else {
            return false
        }
        
        return expiryDate.isBefore(date: Date(), toGranularity: .month)
    }

    private func cardNumberAttributedString() -> NSAttributedString? {
        guard let redactedPrefix = paymentCardType?.redactedPrefix, let pan = paymentCard.fullPan else {
            return nil
        }
        let startIndex = pan.index(pan.endIndex, offsetBy: -4)
        let lastFour = String(pan[startIndex...])

        // https://stackoverflow.com/questions/19487369/center-two-fonts-with-different-different-sizes-vertically-in-an-nsattributedstr?rq=1
        let offset = (UIFont.systemFont(ofSize: 12).capHeight - UIFont.systemFont(ofSize: 12).capHeight) / 2

        let attributedString = NSMutableAttributedString()
        attributedString.append(NSMutableAttributedString(string: redactedPrefix, attributes: [.font: UIFont.systemFont(ofSize: 12), .baselineOffset: offset, .kern: 1.5]))
        attributedString.append(NSMutableAttributedString(string: lastFour, attributes: [.font: UIFont.systemFont(ofSize: 12), .kern: 0.2]))

        return attributedString
    }
}
