//
//  AddPaymentCardViewModel.swift
//  
//
//  Created by Sean Williams on 14/10/2022.
//

import UIKit


class AddPaymentCardViewModel {
    private enum Constants {
        static let expiryYearsInTheFuture = 50
    }
    
    var fields: [FormField] = []
    
    
    init(paymentCard: PaymentCardCreateModel) {
        setupfields(paymentCard: paymentCard)
    }
    
    private func setupfields(paymentCard: PaymentCardCreateModel) {
        let updatedBlock: FormField.ValueUpdatedBlock = { [weak self] field, newValue in
//            guard let self = self else { return }
//            self.delegate?.formDataSource(self, changed: newValue, for: field)
        }
        
        let shouldChangeBlock: FormField.TextFieldShouldChange = { [weak self] (field, textField, range, newValue) in
//            guard let self = self, let delegate = self.delegate else { return true }
//            return delegate.formDataSource(self, textField: textField, shouldChangeTo: newValue, in: range, for: field)
            return true
        }
        
        let pickerUpdatedBlock: FormField.PickerUpdatedBlock = { [weak self] field, options in
//            guard let self = self else { return }
//            self.delegate?.formDataSource(self, selected: options, for: field)
        }
        
        let fieldExitedBlock: FormField.FieldExitedBlock = { [weak self] field in
//            guard let self = self else { return }
//            self.delegate?.formDataSource(self, fieldDidExit: field)
        }

        let manualValidateBlock: FormField.ManualValidateBlock = { [weak self] field in
//            guard let self = self, let delegate = self.delegate else { return false }
            return self?.formDataSource(manualValidate: field) ?? true
        }
        
        let cardNumberField = FormField(
            title: "Card number",
            placeholder: "xxxx xxxx xxxx xxxx",
            validation: nil,
            fieldType: .paymentCardNumber,
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock,
            forcedValue: paymentCard.fullPan
        )
        
        let monthData = Calendar.current.monthSymbols.enumerated().compactMap { index, _ in
            FormPickerData(String(format: "%02d", index + 1), backingData: index + 1)
        }
        
        let yearValue = Calendar.current.component(.year, from: Date())
        let yearData = Array(yearValue...yearValue + Constants.expiryYearsInTheFuture).compactMap { FormPickerData("\($0)", backingData: $0) }

        let expiryField = FormField(
            title: "Expiry",
            placeholder: "MM/YY",
            validation: "^(0[1-9]|1[012])[\\/](19|20)\\d\\d$",
            validationErrorMessage: "Invalid expiry date",
            fieldType: .expiry(months: monthData, years: yearData),
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock,
            pickerSelected: pickerUpdatedBlock,
            manualValidate: manualValidateBlock,
            /// It's fine to force unwrap here, as we are already guarding against the values being nil and we don't want to provide default values
            /// We will never reach the force unwrapping if either value is nil
            forcedValue: paymentCard.month == nil || paymentCard.year == nil ? nil : "\(String(format: "%02d", paymentCard.month ?? 0))/\(paymentCard.year ?? 0)"
        )
        
        let nameOnCardField = FormField(
            title: "Name on card",
            placeholder: "J Appleseed",
            validation: "^(((?=.{1,}$)[A-Za-z\\-\\u00C0-\\u00FF' ])+\\s*)$",
            fieldType: .text,
            updated: updatedBlock,
            shouldChange: shouldChangeBlock,
            fieldExited: fieldExitedBlock,
            forcedValue: paymentCard.nameOnCard
        )
        
        fields = [cardNumberField, expiryField, nameOnCardField]
    }
    
    func formDataSource(manualValidate field: FormField) -> Bool {
        return true
    }

}


struct FormPickerData: Equatable {
    let title: String
    let backingData: Int?
    
    init?(_ title: String?, backingData: Int? = nil) {
        guard let title = title else { return nil }
        
        self.title = title
        self.backingData = backingData
    }
}

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
