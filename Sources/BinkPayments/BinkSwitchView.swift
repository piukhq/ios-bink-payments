//
//  BinkSwitchView.swift
//  
//
//  Created by Sean Williams on 13/12/2022.
//

import UIKit

class BinkSwitchView: UIStackView {
    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        switchView.addTarget(self, action: #selector(handleSwitchChange), for: .valueChanged)
        return switchView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Switch me baby"
        return label
    }()
    
    func configure(themeConfig: BinkThemeConfiguration, text: String?) {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fill
        
        switchView.onTintColor = themeConfig.primaryColor
        
        if let text = text {
            label.text = text
            label.font = themeConfig.textfieldFont
            addArrangedSubview(label)
        }

        addArrangedSubview(switchView)
    }

    
    @objc func handleSwitchChange(_ sender: UISwitch) {
        print("SWITCH")
    }
}


