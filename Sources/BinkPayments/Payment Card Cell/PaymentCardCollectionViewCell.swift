//
//  PaymentCardCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 24/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet private weak var nameOnCardLabel: UILabel!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var providerLogoImageView: UIImageView!
    @IBOutlet private weak var providerWatermarkImageView: UIImageView!
    @IBOutlet private weak var containerView: UIView!

    private enum CardGradientKey: NSString {
        case visaGradient
        case mastercardGradient
        case amexGradient
        case unknownGradient
    }
    
    private var cardGradientLayer: CAGradientLayer?

    func configureWithAddViewModel(_ viewModel: PaymentAccountCreateModel) {
        nameOnCardLabel.text = viewModel.nameOnCard
        cardNumberLabel.attributedText = cardNumberAttributedString(for: viewModel.fullPan ?? "", type: viewModel.cardType)
        configureForProvider(cardType: viewModel.cardType)
        setLabelStyling()
        layer.cornerRadius = 5
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
    }
    
    private func cardNumberAttributedString(for incompletePan: String, type: PaymentCardType?) -> NSAttributedString? {
        let unredacted = 4
        var stripped = incompletePan.replacingOccurrences(of: " ", with: "")
        let cardNumberLength = 16
        let cardNumberLengthFromCardType = type?.lengthRange().length ?? cardNumberLength
        let lengthDiff = cardNumberLength - cardNumberLengthFromCardType
        let whitespaceIndexLocations = [4, 11, 18]
        
        // If the string is too long, cut it from the right
        if stripped.count > cardNumberLength {
            let range = stripped.index(stripped.endIndex, offsetBy: -(cardNumberLength - lengthDiff)) ..< stripped.endIndex
            stripped = String(stripped[range])
        }
        
        let redactTo = cardNumberLength - unredacted
        let offset = max(0, stripped.count - redactTo)
        let length = min(stripped.count, redactTo)
        let endIndex = stripped.index(stripped.endIndex, offsetBy: -offset)
        let range = stripped.startIndex ..< endIndex
        
        // THE AMEX CASE
        if (cardNumberLength - cardNumberLengthFromCardType == 1) && stripped.count >= redactTo {
            stripped.insert("#", at: stripped.startIndex)
        }
        
        var redacted = stripped.replacingCharacters(in: range, with: String(repeating: "•", count: length))
        
        // FORMAT
        let textOffset = (UIFont.systemFont(ofSize: 16).capHeight - UIFont.systemFont(ofSize: 16).capHeight) / 2
        var padRange = 0
        whitespaceIndexLocations.forEach { spaceIndex in
            if redacted.count > spaceIndex {
                let space = "   "
                redacted.insert(contentsOf: space, at: redacted.index(redacted.startIndex, offsetBy: spaceIndex))
                padRange += space.count
            }
        }
        
        /*
        Due to the way UILabel draws itself, we need the lineheight to be set to a constant
        so that when an unredacted character (of a different font size) is added, there is no visual vertical shifting taking
        place. Due to using NSAttributedString we've lost some safety because we have to use NSRange.
        */
        
        let attributedString = NSMutableAttributedString(string: redacted)
        var nsRange = NSRange(range, in: stripped)
        nsRange.length += padRange
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 25 // Discovered via trial and error, come back and fix some other time
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 16), .kern: 1.5, .paragraphStyle: style, .baselineOffset: textOffset], range: nsRange)
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 16), .kern: 0.2], range: NSRange(location: nsRange.length, length: redacted.count - (nsRange.length)))
        
        return attributedString
    }
    
    private func setLabelStyling() {
        nameOnCardLabel.font = .systemFont(ofSize: 16)
        
        [nameOnCardLabel, cardNumberLabel].forEach {
            $0?.textColor = .white
        }
    }
    
    private func configureForProvider(cardType: PaymentCardType?) {
        guard let type = cardType else {
            processGradient(type: cardType)
            providerLogoImageView.image = nil
            providerWatermarkImageView.image = nil
            return
        }

        providerLogoImageView.image = UIImage(named: type.logoName, in: .module, compatibleWith: nil)
        providerWatermarkImageView.image = UIImage(named: type.sublogoName, in: .module, compatibleWith: nil)
        
        processGradient(type: type)
    }
    
    private func processGradient(type: PaymentCardType?) {
        cardGradientLayer?.removeFromSuperlayer()
        let gradient = CAGradientLayer()
        containerView.layer.insertSublayer(gradient, at: 0)
        cardGradientLayer = gradient
        cardGradientLayer?.frame = bounds
        cardGradientLayer?.locations = [0.0, 1.0]
        cardGradientLayer?.startPoint = CGPoint(x: 1.0, y: 0.0)
        cardGradientLayer?.endPoint = CGPoint(x: 0.0, y: 0.0)
        cardGradientLayer?.cornerRadius = 5
        switch type {
        case .visa:
            cardGradientLayer?.colors = UIColor.visaPaymentCardGradients
        case .mastercard:
            cardGradientLayer?.colors = UIColor.mastercardPaymentCardGradients
        case .amex:
            cardGradientLayer?.colors = UIColor.amexPaymentCardGradients
        case .none:
            cardGradientLayer?.colors = UIColor.unknownPaymentCardGradients
        }
    }
}
