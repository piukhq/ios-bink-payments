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
    
    private lazy var textview: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fill
        spacing = 10
    }
    
    init(themeConfig: BinkThemeConfiguration, text: String?) {
        super.init(frame: .zero)
        switchView.onTintColor = themeConfig.primaryColor
        addArrangedSubview(switchView)

        if let text = text {
            textview.text = text
            textview.font = themeConfig.textfieldTitleFont
            addArrangedSubview(textview)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSwitchChange(_ sender: UISwitch) {
        
    }
}


