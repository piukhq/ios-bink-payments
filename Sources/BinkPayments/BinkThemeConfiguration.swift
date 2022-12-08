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
    
    /// Text
    public var title: String = ""
    
    
    /// Textfield
    public var fieldPromptCapitalisationStyle: UITextAutocapitalizationType = .sentences
    public var fieldPromptStyle: FieldPromptStyle = .header
    public var fieldBorderStyle: FieldBorderStyle = .underline
    public var fieldBorderWidth: CGFloat = 2
    public var fieldBorderColor: UIColor = .systemGray2
    public var fieldCursorColor: UIColor = .systemGray
    public var fieldTextColor: UIColor = .label
}
