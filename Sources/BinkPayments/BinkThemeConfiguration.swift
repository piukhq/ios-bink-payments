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
    
    /// Navigation bar title text.
    open var navigationTitle: String = ""
    
    /// Navigation bar back button text.
    open var backButtonTitle: String = ""
    
    
    // Textfield
    
    /// Capitalise the first word in each sentance or every character.
    open var fieldPromptCapitalisationStyle: FieldAutoCapitalisationType = .sentences
    
    /// Situate the textfield header / prompt above the textfield or as the textfield placeholder.
    open var fieldPromptStyle: FieldPromptStyle = .header
    
    /// Choose between a border surrounding the textfield or an underline beneath the textfield's content.
    open var fieldBorderStyle: FieldBorderStyle = .underline
    
    /// The width of the textfield's border or underline.
    open var fieldBorderWidth: CGFloat = 2
    
    /// The color of the textfield's border or underline.
    open var fieldBorderColor: UIColor = .systemGray2
    
    /// The color of the textfield's cursor.
    open var fieldCursorColor: UIColor = .systemGray
    
    /// The color of the textfield's background.
    open var fieldBackgroundColor: UIColor = .quaternarySystemFill
    
    /// The color of the textfield's text.
    open var fieldTextColor: UIColor = .label
    
    
    // Font
    
    /// The font for the navigation bar's title
    open var navigationTitleFont: UIFont = .systemFont(ofSize: 15, weight: .light)
    
    /// The font for the navigations bar's back button title.
    open var navigationBackButtonTitleFont: UIFont = .systemFont(ofSize: 13, weight: .light)
    
    /// The font for the textfield's title (header) or placeholder (inline).
    open var textfieldTitleFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
    
    /// The font for the textfield's text.
    open var textfieldFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
    
    /// The font for the validation label (error message).
    open var validationLabelFont: UIFont = .systemFont(ofSize: 13, weight: .light)

    
    // Images
    
    /// The image for the navigation bar's back button
    open var backIndicatorImage: UIImage?
}
