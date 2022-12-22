//
//  BinkScannerWidgetView.swift
//  binkapp
//
//  Created by Nick Farrant on 06/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BinkScannerWidgetView: UIView {
    enum Constants {
        static let cornerRadius: CGFloat = 8
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var explainerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        return imageView
    }()
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, explainerLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        addSubview(stackView)
        return stackView
    }()
    
    private var state: WidgetState = .enterManually

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 48),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func unrecognizedBarcode() {
        error(state: .unrecognizedCardNumber)
    }

    func timeout() {
        error(state: .timeout)
    }

    func addTarget(_ target: Any?, selector: Selector?) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector))
    }

    func configure() {
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        explainerLabel.font = .systemFont(ofSize: 16, weight: .light)
        explainerLabel.numberOfLines = 2
        setState(state)
    }

    private func error(state: WidgetState) {
        layer.addBinkAnimation(.shake)
        HapticFeedbackUtil.giveFeedback(forType: .error)
        setState(state)
    }

    private func setState(_ state: WidgetState) {
        titleLabel.text = state.title
        explainerLabel.text = state.explainerText
        imageView.image = UIImage(named: state.imageName, in: .module, with: nil)
        self.state = state
    }
}

extension BinkScannerWidgetView {
    enum WidgetState {
        case enterManually
        case unrecognizedCardNumber
        case timeout

        var title: String {
            switch self {
            case .enterManually, .timeout:
                return "Enter manually"
            case .unrecognizedCardNumber:
                return "Unrecognised card number"
            }
        }

        var explainerText: String {
            switch self {
            case .enterManually, .timeout:
                return "You can also type in the card details yourself"
            case .unrecognizedCardNumber:
                return "Please try adding the card manually"
            }
        }

        var imageName: String {
            switch self {
            case .enterManually:
                return "loyalty_scanner_enter_manually"
            case .unrecognizedCardNumber, .timeout:
                return "loyalty_scanner_error"
            }
        }
    }
}
