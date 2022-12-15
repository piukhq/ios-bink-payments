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
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fill
        spacing = 10
    }
    
    func configure(themeConfig: BinkThemeConfiguration, text: String?) {
        switchView.onTintColor = themeConfig.primaryColor
        addArrangedSubview(switchView)

        if let text = text {
            label.text = text
            label.font = themeConfig.textfieldFont
            addArrangedSubview(label)
        }
    }
    
    @objc func handleSwitchChange(_ sender: UISwitch) {
        print("SWITCH")
    }
}


