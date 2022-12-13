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
    public var primaryColor: UIColor = .darkGray
    public var backgroundColor: UIColor = .secondarySystemBackground
    public var titleTextColor: UIColor = .label
    public var navigationBarTintColor: UIColor = .label
    public var navigationBarTitleTextColor: UIColor = .label
    public var navigationBarBackgroundEffect: UIBlurEffect? = .init(style: .light)
    public var navigationBarBackgroundAlpha: CGFloat = 0.6
    
   
    /// Text
    public var navigationTitle: String = ""
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
    
    /// Font
    public var navigationTitleFont: UIFont = .systemFont(ofSize: 15, weight: .light)
    public var navigationBackButtonTitleFont: UIFont = .systemFont(ofSize: 13, weight: .light)

    public var textfieldTitleFont: UIFont = .systemFont(ofSize: 13, weight: .thin)
    public var textfieldFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
    public var validationLabelFont: UIFont = .systemFont(ofSize: 13, weight: .light)

    
    /// Images
    public var backIndicatorImage: UIImage?
}
