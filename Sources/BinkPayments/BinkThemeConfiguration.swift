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
    
    public enum FieldAutoCapitalisationType {
        case sentences
        case allCharacters
    }
    
    public init() {}
    
    
    /// Colors
    public var primaryColor: UIColor = .clear
    public var backgroundColor: UIColor = .systemBackground
    public var titleTextColor: UIColor = .label
    public var navigationBarTintColor: UIColor = .label
    
   
    /// Text
    public var title: String = ""
    public var backButtonTitle: String = ""
    
    
    /// Textfield
    public var fieldPromptCapitalisationStyle: FieldAutoCapitalisationType = .sentences
    public var fieldPromptStyle: FieldPromptStyle = .header
    public var fieldBorderStyle: FieldBorderStyle = .underline
    public var fieldBorderWidth: CGFloat = 2
    public var fieldBorderColor: UIColor = .systemGray2
    public var fieldCursorColor: UIColor = .systemGray
    public var fieldBackgroundColor: UIColor = .quaternarySystemFill
    public var fieldTextColor: UIColor = .label

    
    /// Images
    public var backIndicatorImage: UIImage?
}
