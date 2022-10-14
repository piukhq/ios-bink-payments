//
//  MultipleChoiceInput.swift
//  binkapp
//
//  Created by Max Woodhams on 15/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol FormMultipleChoiceInputDelegate: NSObjectProtocol {
    func multipleChoiceInputDidUpdate(newValue: String?, backingData: [Int]?)
    func multipleChoiceSeparatorForMultiValues() -> String?
}

class FormMultipleChoiceInput: UIInputView {
    var fullContentString = ""
    var backingData: [Int]?
    
    // MARK: - Properties
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        defer {
            if prepopulateDefaults {
                sections.enumerated().forEach { component, _ in pickerSelected(component, index: 0) }
            }
        }
        addSubview(picker)
        return picker
    }()
    
    private let sections: [[FormPickerData]]
    private var selectedContent: [Int: FormPickerData] = [:] {
        didSet {
            var lastString: String?
            fullContentString = ""
            
            // Reset backingData from last call
            backingData = []
            
            selectedContent.sorted(by: { $0.key < $1.key }).forEach { _, value in
                if let separator = delegate?.multipleChoiceSeparatorForMultiValues(), lastString != nil {
                    fullContentString += "\(separator)"
                }
                
                fullContentString += value.title
                
                if let backingDataValue = value.backingData {
                    backingData?.append(backingDataValue)
                }
                
                lastString = value.title
            }
            
            delegate?.multipleChoiceInputDidUpdate(newValue: fullContentString, backingData: backingData)
        }
    }

    weak var delegate: FormMultipleChoiceInputDelegate?
    let prepopulateDefaults: Bool
    
    // MARK: - Initialisation
    
    public init(with sections: [[FormPickerData]], delegate: FormMultipleChoiceInputDelegate, prepopulateDefaults: Bool = false) {
        self.sections = sections
        self.delegate = delegate
        self.prepopulateDefaults = prepopulateDefaults
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 250), inputViewStyle: .keyboard)
        allowsSelfSizing = true
        configureAutolayout()
        
        fullContentString = sections.first?.first?.title ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This view has no related XIB or Storyboard")
    }
    
    // MARK: - Configuration
    
    private func configureAutolayout() {
        let safeArea = safeAreaLayoutGuide
        
        let common = [
            pickerView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
            pickerView.rightAnchor.constraint(equalTo: safeArea.rightAnchor),
            pickerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(common)
    }
    
    // MARK: - Actions
    
    private func pickerSelected(_ component: Int, index: Int) {
        if let component = sections[safe: component], let row = component[safe: index], let index = sections.firstIndex(of: component) {
            selectedContent[index] = row
        }
    }
    
    @objc fileprivate func doneInputView() {
        endEditing(true)
        //        textfield.resignFirstResponder()
    }
}

// MARK: - Selectors

private extension Selector {
    static let done = #selector(FormMultipleChoiceInput.doneInputView)
}

// MARK: - UIPickerViewDataSource

extension FormMultipleChoiceInput: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return sections.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sections[component].count
    }
}

extension FormMultipleChoiceInput: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 42
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel
        
        if view == nil {
            pickerLabel = UILabel()
            pickerLabel.numberOfLines = 3
            pickerLabel.lineBreakMode = .byTruncatingTail
            pickerLabel.textAlignment = .center
            pickerLabel.minimumScaleFactor = 0.5
            pickerLabel.adjustsFontSizeToFitWidth = true
        } else {
            guard let label = view as? UILabel else {
                return UIView()
            }
            pickerLabel = label
        }
        
        pickerLabel.text = sections[component][row].title
        return pickerLabel
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelected(component, index: row)
    }
}
