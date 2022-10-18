//
//  FormField.swift
//  
//
//  Created by Sean Williams on 18/10/2022.
//

import UIKit

class FormField {
    enum FieldInputType: Equatable {
        case text
        case paymentCardNumber
        case expiry(months: [FormPickerData], years: [FormPickerData])
        
        func keyboardType() -> UIKeyboardType {
            switch self {
            case .text:
                return .default
            case .paymentCardNumber:
                return .numberPad
            default:
                return .default
            }
        }
        
        func capitalization() -> UITextAutocapitalizationType {
            switch self {
            case .text:
                return .words
            default:
                return .none
            }
        }
        
        func autoCorrection() -> UITextAutocorrectionType {
            return .no
        }
    }

    let title: String
    let placeholder: String
    let validation: String?
    let validationErrorMessage: String?
    let fieldType: FieldInputType
    let valueUpdated: ValueUpdatedBlock
    let fieldExited: FieldExitedBlock
    let pickerOptionsUpdated: PickerUpdatedBlock?
    let shouldChange: TextFieldShouldChange
    let manualValidate: ManualValidateBlock?
    let forcedValue: String?
    let isReadOnly: Bool
    let dataSourceRefreshBlock: DataSourceRefreshBlock?
    let hidden: Bool
    private(set) var value: String?
    
    typealias ValueUpdatedBlock = (FormField, String?) -> Void
    typealias PickerUpdatedBlock = (FormField, [Any]) -> Void
    typealias TextFieldShouldChange = (FormField, UITextField, NSRange, String?) -> (Bool)
    typealias FieldExitedBlock = (FormField) -> Void
    typealias ManualValidateBlock = (FormField) -> (Bool)
    typealias DataSourceRefreshBlock = () -> Void
        
    init(title: String, placeholder: String, validation: String?, validationErrorMessage: String? = nil, fieldType: FieldInputType, value: String? = nil, updated: @escaping ValueUpdatedBlock, shouldChange: @escaping TextFieldShouldChange, fieldExited: @escaping FieldExitedBlock, pickerSelected: PickerUpdatedBlock? = nil, manualValidate: ManualValidateBlock? = nil, forcedValue: String? = nil, isReadOnly: Bool = false, dataSourceRefreshBlock: DataSourceRefreshBlock? = nil, hidden: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self.validation = validation
        self.validationErrorMessage = validationErrorMessage
        self.fieldType = fieldType
        self.value = value
        self.valueUpdated = updated
        self.shouldChange = shouldChange
        self.fieldExited = fieldExited
        self.pickerOptionsUpdated = pickerSelected
        self.manualValidate = manualValidate
        self.forcedValue = forcedValue
        self.value = forcedValue // Initialise the field's value with any forced value. If there isn't a forced value, the value will default to nil as normal.
        self.isReadOnly = isReadOnly
        self.dataSourceRefreshBlock = dataSourceRefreshBlock
        self.hidden = hidden
    }
    
    func isValid() -> Bool {
        // If the field has manual validation, apply it
        if let validateBlock = manualValidate {
            return validateBlock(self)
        }
        
        // If our value is unset then we do not pass the validation check
        guard let value = value else { return false }
        
        if fieldType == .paymentCardNumber {
            return PaymentCardType.validate(fullPan: value)
        } else {
            guard let validation = validation else { return !value.isEmpty || !value.isBlank }
            
            let predicate = NSPredicate(format: "SELF MATCHES %@", validation)
            return predicate.evaluate(with: value)
        }
    }
    
    func updateValue(_ value: String?) {
        self.value = value
        valueUpdated(self, value)
    }
    
    func pickerDidSelect(_ options: [Any]) {
        pickerOptionsUpdated?(self, options)
    }
    
    func fieldWasExited() {
        fieldExited(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeInRange: NSRange, newValue: String?) -> Bool {
        return shouldChange(self, textField, shouldChangeInRange, newValue)
    }
}
