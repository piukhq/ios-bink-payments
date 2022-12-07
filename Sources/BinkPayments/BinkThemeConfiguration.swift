//
//  BinkThemeConfiguration.swift
//  TestAppPaymentsSDK
//
//  Created by Sean Williams on 07/12/2022.
//

import UIKit

public class BinkThemeConfiguration {
    public enum FieldPromptStyle {
        case header
        case inline
    }
    
    public enum FieldBorderStyle {
        case box
        case underline
    }
    
    public init() {}
    
    
    /// Colors
    public var backgroundColor: UIColor = .systemBackground
    public var titleTextColor: UIColor = .label
    public var textfieldTextColor: UIColor = .label
    
    /// Text
    public var title: String = ""
    
    
    /// Textfield
    public var fieldPromptStyle: FieldPromptStyle = .header
    public var fieldPromptCapitalisationStyle: UITextAutocapitalizationType = .sentences
    public var fieldBorderStyle: FieldBorderStyle = .underline
    public var fieldBorderColor: UIColor = .systemPink
    public var fieldBorderWidth: CGFloat = 2
}
