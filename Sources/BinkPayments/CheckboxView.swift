//
//  CheckboxView.swift
//
//  Copyright © 2022 Bink. All rights reserved.
//

import UIKit

class CheckboxView: CustomView {
    @IBOutlet private weak var checkboxButtonExtendedTappableAreaView: UIView!
    @IBOutlet private weak var checkboxButton: UIButton!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var textViewLeadingConstraint: NSLayoutConstraint!
    
    private var checkedState = false
    private(set) var hideCheckbox = false
    private(set) var isOptional = false
    
    var value: String {
        return checkedState ? "1" : "0"
    }
    
    private lazy var textViewGesture = UITapGestureRecognizer(target: self, action: .handleCheckboxTap)
    private lazy var checkboxGesture = UITapGestureRecognizer(target: self, action: .handleCheckboxTap)
    private var themeConfig: BinkThemeConfiguration

    
    init(checked: Bool, themeConfig: BinkThemeConfiguration, title: String? = nil, isOptional: Bool = false, hideCheckbox: Bool = false) {
        self.themeConfig = themeConfig
        self.checkedState = checked
        self.isOptional = isOptional
        self.hideCheckbox = hideCheckbox
        super.init(frame: .zero)

        if hideCheckbox {
            checkboxButton.isHidden = true
            checkboxButtonExtendedTappableAreaView.isHidden = true
            textView.textContainer.lineFragmentPadding = 0
            textViewLeadingConstraint.constant = -(checkboxButtonExtendedTappableAreaView.frame.width - 11)
        }

        textView.text = title
        textView.textColor = themeConfig.titleTextColor
        textView.font = themeConfig.textfieldTitleFont
        configureCheckboxButton(forState: checkedState, animated: false)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        textView.isUserInteractionEnabled = true
        textView.addGestureRecognizer(textViewGesture)
        checkboxButtonExtendedTappableAreaView.addGestureRecognizer(checkboxGesture)
    }
    
    @IBAction private func toggleCheckbox() {
        checkedState.toggle()
        configureCheckboxButton(forState: checkedState)
    }
    
    private func configureCheckboxButton(forState checked: Bool, animated: Bool = true) {
        let animationBlock = {
            self.checkboxButton.backgroundColor = checked ? self.themeConfig.primaryColor : self.themeConfig.fieldBackgroundColor
            self.checkboxButton.setImage(checked ? UIImage(systemName: "checkmark") : nil, for: .normal)
            self.checkboxButton.layer.borderColor = checked ? nil : self.themeConfig.fieldBorderColor.cgColor
            self.checkboxButton.layer.borderWidth = checked ? 0 : 2
        }
        
        guard animated else {
            animationBlock()
            return
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionFlipFromTop, animations: {
            animationBlock()
        }, completion: nil)
    }
    
    @objc func handleCheckboxTap() {
        toggleCheckbox()
    }
}

extension CheckboxView {
    var isValid: Bool {
        if hideCheckbox {
            return true
        }
        return isOptional ? true : checkedState
    }
}

fileprivate extension Selector {
    static let handleCheckboxTap = #selector(CheckboxView.handleCheckboxTap)
}
