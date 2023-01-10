//
//  BinkThemeConfiguration.swift
//  TestAppPaymentsSDK
//
//  Created by Sean Williams on 07/12/2022.
//

import UIKit

/// Initialise a BinkThemeConfiguration object and override any properties to match your application's theme.
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
    
    
    // Colors
    
    /// The background color of navigation bars, checkboxes and switches.
    open var primaryColor: UIColor = .darkGray
    
    /// The view controller background color
    open var backgroundColor: UIColor = .secondarySystemBackground
    
    /// The textfield, switch and checkbox text color.
    open var titleTextColor: UIColor = .label
    
    /// This applies to the back button, the back button title and close button color on the navigation bar.
    open var navigationBarTintColor: UIColor = .label
    
    /// The text color of the view controller's title in the navigation bar.
    open var navigationBarTitleTextColor: UIColor = .label
    
    /// The blur effect applied to the navigation bar.
    open var navigationBarBackgroundEffect: UIBlurEffect? = .init(style: .light)
    
    /// The alpha value applied to the navigation bar.
    open var navigationBarBackgroundAlpha: CGFloat = 0.6
    
   
    // Text
    open var navigationTitle: String = ""
    open var backButtonTitle: String = ""
    
    
    // Textfield
    open var fieldPromptCapitalisationStyle: FieldAutoCapitalisationType = .sentences
    
    /// Situate the textfield header / prompt above the textfield or as the textfield placeholder.
    open var fieldPromptStyle: FieldPromptStyle = .header
    
    open var fieldBorderStyle: FieldBorderStyle = .underline
    open var fieldBorderWidth: CGFloat = 2
    open var fieldBorderColor: UIColor = .systemGray2
    open var fieldCursorColor: UIColor = .systemGray
    open var fieldBackgroundColor: UIColor = .quaternarySystemFill
    open var fieldTextColor: UIColor = .label
    
    
    // Font
    open var navigationTitleFont: UIFont = .systemFont(ofSize: 15, weight: .light)
    open var navigationBackButtonTitleFont: UIFont = .systemFont(ofSize: 13, weight: .light)
    open var textfieldTitleFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
    open var textfieldFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
    open var validationLabelFont: UIFont = .systemFont(ofSize: 13, weight: .light)

    
    // Images
    open var backIndicatorImage: UIImage?
}
