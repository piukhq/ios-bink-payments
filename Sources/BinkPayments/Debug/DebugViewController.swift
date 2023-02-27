//
//  DebugViewController.swift
//  
//
//  Created by Sean Williams on 12/10/2022.
//

import UIKit

/// Debug screen tat displays info about a payment card
public class DebugViewController: UIViewController {
    private lazy var panLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var expiryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameOnCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [panLabel, expiryLabel, nameOnCardLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.backgroundColor = .darkGray
        stackView.layer.borderColor = UIColor.systemPink.cgColor
        stackView.layer.borderWidth = 1
        stackView.layoutMargins = UIEdgeInsets(top: 30, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layer.cornerRadius = 15
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close", in: .module, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.tintColor = .systemPink
        view.addSubview(button)
        return button
    }()
    
    public var paymentCard: PaymentAccountCreateModel
    
    public init(paymentCard: PaymentAccountCreateModel) {
        self.paymentCard = paymentCard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 20),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        view.backgroundColor = .darkGray
        panLabel.text = paymentCard.fullPan
        expiryLabel.text = paymentCard.formattedExpiryDate()
        nameOnCardLabel.text = paymentCard.nameOnCard
    }
    
    @objc public func close() {
        dismiss(animated: true)
    }
}
