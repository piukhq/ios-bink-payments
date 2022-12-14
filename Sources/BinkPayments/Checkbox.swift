//
//  Checkbox.swift
//  
//
//  Created by Sean Williams on 14/12/2022.
//

import UIKit

class Checkbox: UIButton {

//    private lazy var addButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = .systemPink
//        button.setTitle("CHECKBOX", for: .normal)
////        button.layer.cornerRadius = Constants.buttonCornerRadius
//        button.layer.cornerCurve = .continuous
//        button.tintColor = .label
//        button.isEnabled = true
//        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//        addSubview(button)
//        return button
//    }()
    
    private var checkedState: Bool
    private var text: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemPink
        setTitle("CHECKBOX", for: .normal)
        layer.cornerCurve = .continuous
        tintColor = .label
        isEnabled = true
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40),
            widthAnchor.constraint(equalToConstant: 40)
            ])
    }
    
    init(checkedState: Bool, text: String?) {
        self.checkedState = checkedState
        self.text = text
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTapped() {
        print("YO")
    }
    
}
