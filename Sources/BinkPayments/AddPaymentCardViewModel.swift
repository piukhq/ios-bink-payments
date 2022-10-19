//
//  AddPaymentCardViewModel.swift
//  
//
//  Created by Sean Williams on 14/10/2022.
//

import Combine
import UIKit


class AddPaymentCardViewModel {
    private enum Constants {
        static let expiryYearsInTheFuture = 50
    }
     
    @Published var paymentCard: PaymentCardCreateModel
    @Published var fullFormIsValid = false
    @Published var refreshForm = false
    
    var fields: [FormField] = []

    init(paymentCard: PaymentCardCreateModel? = nil) {
        self.paymentCard = paymentCard ?? PaymentCardCreateModel(fullPan: nil, nameOnCard: nil, month: nil, year: nil)
        setupfields(paymentCard: self.paymentCard)
    }
    
    func refreshDataSource() {
        setupfields(paymentCard: paymentCard)
        refreshForm = true
        checkFormValidity()
    }
    
    private func checkFormValidity() {
        fullFormIsValid = fields.allSatisfy { $0.isValid() }
    }

    private func setupfields(paymentCard: PaymentCardCreateModel) {
        let updatedBlock: FormField.ValueUpdatedBlock = { [weak self] field, newValue in
            guard let self = self else { return }
            self.textField(changed: newValue, for: field)
        }
        
        let shouldChangeBlock: FormField.TextFieldShouldChange = { [weak self] (field, textField, range, newValue) in
            guard let self = self else { return false }
            return self.textFieldShouldChange(textField, shouldChangeTo: newValue, in: range, for: field)
        }
        
        let pickerUpdatedBlock: FormField.PickerUpdatedBlock = { [weak self] field, options in
            guard let self = self else { return }
            self.picker(selected: options, for: field)
        }
        
        let fieldExitedBlock: FormField.FieldExitedBlock = { [weak self] field in
            guard let self = self else { return }
            self.textField(didExit: field)
        }

        let manualValidateBlock: FormField.ManualValidateBlock = { [weak self] field in
            guard let self = self else { return false }
            return self.textField(manualValidate: field)
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
    
    private func textField(manualValidate field: FormField) -> Bool {
        switch field.fieldType {
        case .expiry(months: _, years: _):
            // Create date using components from string e.g. 11/2019
            guard let dateStrings = field.value?.components(separatedBy: "/") else { return false }
            guard let monthString = dateStrings[safe: 0] else { return false }
            guard let yearString = dateStrings[safe: 1] else { return false }
            guard let month = Int(monthString) else { return false }
            guard let year = Int(yearString) else { return false }
            guard let expiryDate = Date.makeDate(year: year, month: month, day: 01, hr: 12, min: 00, sec: 00) else { return false }
            
            return expiryDate.monthHasNotExpired
        default:
            return false
        }
    }
    
    private func textField(changed value: String?, for field: FormField) {
        if field.fieldType == .paymentCardNumber {
            let type = PaymentCardType.type(from: value)
            paymentCard.cardType = type
            paymentCard.fullPan = value
        }
        
        if field.fieldType == .text { paymentCard.nameOnCard = value }
        paymentCard = paymentCard
    }
    
    private func textFieldShouldChange(_ textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        if let type = paymentCard.cardType, let newValue = newValue, let text = textField.text, field.fieldType == .paymentCardNumber {
            /*
            Potentially "needlessly" complex, but the below will insert whitespace to format card numbers correctly according
            to the pattern available in PaymentCardType.
            EXAMPLE: 4242424242424242 becomes 4242 4242 4242 4242
            */
            
            if !newValue.isEmpty {
                let values = type.lengthRange()
                let cardLength = values.length + values.whitespaceIndexes.count
                
                if let textFieldText = textField.text, values.whitespaceIndexes.contains(range.location) && !newValue.isEmpty {
                    textField.text = textFieldText + " "
                }
                
                if text.count >= cardLength && range.length == 0 {
                    return false
                } else {
                    let filtered = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                    return newValue == filtered
                }
            } else {
                // If newValue length is 0 then we can assume this is a delete, and if the next character after
                // this one is a whitespace string then let's remove it.
                
                let secondToLastCharacterLocation = range.location - 1
                if secondToLastCharacterLocation > 0, text.count > secondToLastCharacterLocation {
                    let stringRange = text.index(text.startIndex, offsetBy: secondToLastCharacterLocation)
                    let secondToLastCharacter = text[stringRange]
                    
                    if secondToLastCharacter == " " {
                        var mutableText = text
                        mutableText.remove(at: stringRange)
                        textField.text = mutableText
                    }
                }
                
                return true
            }
        }
        
        return true
    }

    private func picker(selected options: [Any], for field: FormField) {
        // For mapping to the payment card expiry fields, we only care if we have BOTH
        guard options.count > 1 else { return }
        paymentCard.month = options.first as? Int
        paymentCard.year = options.last as? Int
    }
    
    func textField(didExit: FormField) {
        checkFormValidity()
    }
}
