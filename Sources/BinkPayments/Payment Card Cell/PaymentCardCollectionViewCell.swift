//
//  PaymentCardCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 24/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardCollectionViewCell: WalletCardCollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet private weak var nameOnCardLabel: UILabel!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var providerLogoImageView: UIImageView!
    @IBOutlet private weak var providerWatermarkImageView: UIImageView!
    
    private enum CardGradientKey: NSString {
        case visaGradient
        case mastercardGradient
        case amexGradient
        case unknownGradient
        case swipeGradient
    }
    
    private lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    private lazy var height: NSLayoutConstraint = {
        let height = contentView.heightAnchor.constraint(equalToConstant: bounds.size.height)
        height.isActive = true
        return height
    }()
    
    private var cardGradientLayer: CAGradientLayer?
    private var startingOffset: CGFloat = 0
    
    private var viewModel: PaymentCardCellViewModel!
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        processGradient(type: viewModel.paymentCardType)
    }
    
    func configureWithViewModel(_ viewModel: PaymentCardCellViewModel) {
        self.viewModel = viewModel
        
        nameOnCardLabel.text = viewModel.nameOnCardText
        cardNumberLabel.attributedText = viewModel.cardNumberText
        
        configureForProvider(cardType: viewModel.paymentCardType)
        
        setLabelStyling()
        setupShadow()
        accessibilityIdentifier = viewModel.nameOnCardText
    }
    
    func configureWithAddViewModel(_ viewModel: PaymentCardCreateModel) {
        nameOnCardLabel.text = viewModel.nameOnCard
        cardNumberLabel.attributedText = cardNumberAttributedString(for: viewModel.fullPan ?? "", type: viewModel.cardType)
        
        configureForProvider(cardType: viewModel.cardType)
        
        setLabelStyling()
        setupShadow()
        layer.cornerRadius = 5
        layer.cornerCurve = .continuous
    }
    
    private func cardNumberAttributedString(for incompletePan: String, type: PaymentCardType?) -> NSAttributedString? {
        let unredacted = 4
        var stripped = incompletePan.replacingOccurrences(of: " ", with: "")
        let cardNumberLength = 16 // Hardcoded, fix later
        let cardNumberLengthFromCardType = type?.lengthRange().length ?? cardNumberLength
        let lengthDiff = cardNumberLength - cardNumberLengthFromCardType
        let whitespaceIndexLocations = [4, 11, 18] // Harcoded, fix later
        
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
        let textOffset = (UIFont.systemFont(ofSize: 12).capHeight - UIFont.systemFont(ofSize: 12).capHeight) / 2
        var padRange = 0
        whitespaceIndexLocations.forEach { spaceIndex in
            if redacted.count > spaceIndex {
                let space = "   "
                redacted.insert(contentsOf: space, at: redacted.index(redacted.startIndex, offsetBy: spaceIndex))
                padRange += space.count
            }
        }
        
        /*
        The below is kind of a nightmare. Due to the way UILabel draws itself, we need the lineheight to be set to a constant
        so that when an unredacted character (of a different font size) is added, there is no visual vertical shifting taking
        place. Due to using NSAttributedString we've lost some safety because we have to use NSRange.
        */
        
        let attributedString = NSMutableAttributedString(string: redacted)
        var nsRange = NSRange(range, in: stripped)
        nsRange.length += padRange
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 25 // Discovered via trial and error, come back and fix some other time
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 12), .kern: 1.5, .paragraphStyle: style, .baselineOffset: textOffset], range: nsRange)
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 12), .kern: 0.2], range: NSRange(location: nsRange.length, length: redacted.count - (nsRange.length)))
        
        return attributedString
    }
    
    private func setLabelStyling() {
        nameOnCardLabel.font = .systemFont(ofSize: 12)
        
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

        providerLogoImageView.image = UIImage(named: type.logoName, in: .module, with: nil)
        providerWatermarkImageView.image = UIImage(named: type.sublogoName, in: .module, with: nil)
        processGradient(type: type)
    }
    
//    private func configurePaymentCardLinkingStatus() {
//        guard !viewModel.paymentCardIsExpired else {
//            alertView.configureForType(.paymentExpired) { [weak self] in
//                self?.viewModel.expiredAction()
//            }
//            alertView.isHidden = false
//            statusLabel.isHidden = true
//            statusImageView.isHidden = true
//            return
//        }
//
//        statusLabel.text = viewModel.statusText
//        statusImageView.isHidden = !viewModel.paymentCardIsActive
//        statusImageView.image = imageForLinkedStatus()
//    }
    
//    private func imageForLinkedStatus() -> UIImage? {
//        return viewModel.paymentCardIsLinkedToMembershipCards ? Asset.linked.image : Asset.unlinked.image
//    }
    
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
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.priority = UILayoutPriority(999)
        width.constant = bounds.size.width
        height.constant = bounds.size.height
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: targetSize.height))
    }
}
