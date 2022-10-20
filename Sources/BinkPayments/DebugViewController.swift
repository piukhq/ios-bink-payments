//
//  DebugViewController.swift
//  
//
//  Created by Sean Williams on 12/10/2022.
//

import UIKit

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
    
    private lazy var closeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "close", in: .module, with: nil))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemPink
//        imageView.addTarget(self, action: #selector(close), for: .touchUpInside)
            let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        return imageView
    }()
    
    public var paymentCard: PaymentCardCreateModel
    
    public init(paymentCard: PaymentCardCreateModel) {
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
            closeImageView.heightAnchor.constraint(equalToConstant: 20),
            closeImageView.widthAnchor.constraint(equalToConstant: 20),
            closeImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        view.backgroundColor = .darkGray
        panLabel.text = paymentCard.fullPan
        expiryLabel.text = paymentCard.formattedExpiryDate()
        nameOnCardLabel.text = paymentCard.nameOnCard
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}
