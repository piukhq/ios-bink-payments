//
//  CheckboxView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class CheckboxView: CustomView {
    typealias TextAction = () -> Void
    @IBOutlet private weak var checkboxButtonExtendedTappableAreaView: UIView!
    @IBOutlet private weak var checkboxButton: UIButton!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var textViewLeadingConstraint: NSLayoutConstraint!
    
    private var checkedState = false
    private(set) var hideCheckbox = false
    private(set) var optional = false
    private(set) var textSelected: TextAction?
    private(set) var title: NSMutableAttributedString? {
        didSet {
            textView.attributedText = title
        }
    }
    
    var value: String {
        return checkedState ? "1" : "0"
    }
    
    private lazy var textViewGesture = UITapGestureRecognizer(target: self, action: .handleCheckboxTap)
    private lazy var checkboxGesture = UITapGestureRecognizer(target: self, action: .handleCheckboxTap)

    
    init(checked: Bool) {
        super.init(frame: .zero)
        checkedState = checked
        configureCheckboxButton(forState: checkedState, animated: false)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: NSMutableAttributedString, columnName: String, url: URL? = nil, optional: Bool = false, textSelected: TextAction? = nil, hideCheckbox: Bool = false) {
        checkboxButton.layer.cornerRadius = 4
        checkboxButton.layer.cornerCurve = .continuous
   
        self.optional = optional
        self.textSelected = textSelected
        self.hideCheckbox = hideCheckbox

        // We don't need a delegate if we don't have a checkbox, so we send a nil delegate to hide it

        if hideCheckbox {
            checkboxButton.isHidden = true
            checkboxButtonExtendedTappableAreaView.isHidden = true
            textView.textContainer.lineFragmentPadding = 0
            textViewLeadingConstraint.constant = -(checkboxButtonExtendedTappableAreaView.frame.width - 11)
        }

        guard let safeUrl = url else {
            self.title = title
            return
        }

        let attributedString = title
        attributedString.addAttribute(.link, value: safeUrl, range: NSRange(location: title.length - columnName.count, length: columnName.count))
        textView.attributedText = attributedString
        textView.textColor = .cyan
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
            self.checkboxButton.backgroundColor = checked ? .black : .white
            self.checkboxButton.setImage(checked ? UIImage(systemName: "Checkmark") : nil, for: .normal)
            self.checkboxButton.layer.borderColor = checked ? nil : UIColor.systemGray.cgColor
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
    
    /// Should only be used when the API call triggered by the delegate method fails, and we need to revert the state
    func reset() {
        checkedState.toggle()
        configureCheckboxButton(forState: checkedState)
    }
    
    @objc func handleCheckboxTap() {
        toggleCheckbox()
    }
}

//extension CheckboxView: InputValidation {
//    var isValid: Bool {
//        if hideCheckbox {
//            return true
//        }
//        return optional ? true : checkedState
//    }
//}

fileprivate extension Selector {
    static let handleCheckboxTap = #selector(CheckboxView.handleCheckboxTap)
}
