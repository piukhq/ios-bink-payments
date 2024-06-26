//
//  FormCollectionViewCell.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol FormCollectionViewCellDelegate: AnyObject {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField)
    func formCollectionViewCellDidReceivePaymentScannerButtonTap(_ cell: FormCollectionViewCell)
}

class FormCollectionViewCell: UICollectionViewCell {
    private weak var delegate: FormCollectionViewCellDelegate?
    // MARK: - Helpers
    
    private enum Constants {
        static let titleLabelHeight: CGFloat = 20.0
        static let textFieldHeight: CGFloat = 24.0
        static let validationLabelHeight: CGFloat = 20.0
        static let cornerRadius: CGFloat = 5
    }

    // MARK: - Properties
    
    /// The parent stack view that is pinned to the content view of the cell. Contains all other views.
    private lazy var containerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, fieldContainerVStack, validationMessagesVStack])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        contentView.addSubview(stackView)
        return stackView
    }()
    
    /// The white background visual field view that contains all user interacion elements
    private lazy var fieldContainerVStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textFieldHStack])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.layer.cornerCurve = .continuous
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.clipsToBounds = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: .handleCellTap)
        stackView.addGestureRecognizer(gestureRecognizer)
        stackView.isUserInteractionEnabled = true
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    /// The view that contains the text field and camera icon
    private lazy var textFieldHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, textFieldRightView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        contentView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: Constants.titleLabelHeight).isActive = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        field.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight).isActive = true
        field.addTarget(self, action: .textFieldUpdated, for: .editingChanged)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        field.smartQuotesType = .no // This stops the "smart" apostrophe setting. The default breaks field regex validation
        return field
    }()
 
    /// Camera icon
    lazy var textFieldRightView: UIView = {
        let cameraButton = UIButton(type: .custom)
        cameraButton.setImage(UIImage(named: "scanIcon", in: .module, with: nil), for: .normal)
        cameraButton.imageView?.contentMode = .scaleAspectFill
        cameraButton.addTarget(self, action: .handleScanButtonTap, for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setContentHuggingPriority(.required, for: .horizontal)
        return cameraButton
    }()
    
    private lazy var stackBackgroundView: UIView = {
        // Remove when we drop iOS 13 - add validation view to fieldContainerVStack
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.cornerCurve = .continuous
        view.addSubview(underlineView)
        view.clipsToBounds = true
        return view
    }()
    
    /// The underline border
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var validationMessagesVStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [validationLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        contentView.addSubview(stackView)
        return stackView
    }()
    
    /// The label that describes a validation error
    private lazy var validationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Invalid entry"
        label.isHidden = true
        label.textColor = .systemRed
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var inputAccessory: UIToolbar = {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: .accessoryDoneTouchUpInside)
        bar.items = [flexSpace, done]
        bar.sizeToFit()
        return bar
    }()
    
    private var preferredWidth: CGFloat = 300
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutAttributes.frame.size.width = preferredWidth
        layoutAttributes.bounds.size.height = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        return layoutAttributes
    }
    
    private weak var formField: FormField?
    private var pickerSelectedChoice: String?
    private var themeConfig: BinkThemeConfiguration!
    
    // MARK: - Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureLayout() {
        let topConstraint = containerStack.topAnchor.constraint(equalTo: contentView.topAnchor)
        topConstraint.priority = .required
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: containerStack.bottomAnchor)
        bottomConstraint.priority = .required
        
        NSLayoutConstraint.activate([
            containerStack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            containerStack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            topConstraint,
            bottomConstraint,
            underlineView.leftAnchor.constraint(equalTo: stackBackgroundView.leftAnchor),
            underlineView.rightAnchor.constraint(equalTo: stackBackgroundView.rightAnchor),
            underlineView.bottomAnchor.constraint(equalTo: stackBackgroundView.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods

    func configure(with field: FormField, themeConfig: BinkThemeConfiguration, delegate: FormCollectionViewCellDelegate?) {
        self.themeConfig = themeConfig
        textField.text = field.forcedValue
        textField.keyboardType = field.fieldType.keyboardType()
        textField.autocorrectionType = field.fieldType.autoCorrection()
        textField.autocapitalizationType = field.fieldType.capitalization()
        textField.clearButtonMode = .whileEditing
        textField.accessibilityIdentifier = field.title
        textField.returnKeyType = .done
        formField = field
        
        // Remove when we drop iOS 13 - add validation view to fieldContainerVStack
        fieldContainerVStack.insertSubview(stackBackgroundView, at: 0)
        stackBackgroundView.pin(to: fieldContainerVStack)
        
        configureTextFieldRightView(shouldDisplay: formField?.value == nil)
        validationLabel.isHidden = textField.text?.isEmpty == true ? true : field.isValid()

        textField.inputAccessoryView = inputAccessory
        
        if case let .expiry(months, years) = field.fieldType {
            textField.inputView = FormMultipleChoiceInput(with: [months, years], delegate: self)
        } else {
            textField.inputView = nil
        }
        
        self.delegate = delegate
        configureTheme(field)
    }
    
    func setWidth(_ width: CGFloat) {
        preferredWidth = width
    }
    
    private func configureTheme(_ field: FormField) {
        let config = themeConfig ?? BinkThemeConfiguration()
        titleLabel.textColor = config.titleTextColor
        titleLabel.font = config.textfieldTitleFont
        textField.textColor = config.fieldTextColor
        textField.tintColor = config.fieldCursorColor
        textField.font = config.textfieldFont
        validationLabel.font = config.validationLabelFont
        stackBackgroundView.backgroundColor = config.fieldBackgroundColor
        let fieldTitle = config.fieldPromptCapitalisationStyle == .allCharacters ? field.title.uppercased() : field.title
        
        switch config.fieldPromptStyle {
        case .header:
            titleLabel.text = fieldTitle
        case .inline:
            textField.attributedPlaceholder = NSAttributedString(string: fieldTitle, attributes: [
                .foregroundColor: config.titleTextColor.withAlphaComponent(0.5),
                .font: config.textfieldTitleFont
            ])
        }
        
        switch config.fieldBorderStyle {
        case .box:
            stackBackgroundView.layer.borderColor = config.fieldBorderColor.cgColor
            stackBackgroundView.layer.borderWidth = config.fieldBorderWidth
        case .underline:
            underlineView.isHidden = false
            underlineView.backgroundColor = config.fieldBorderColor
            underlineView.heightAnchor.constraint(equalToConstant: config.fieldBorderWidth).isActive = true
        }
    }
    
    // MARK: - Actions
    
    @objc func textFieldUpdated(_ textField: UITextField) {
        guard let textFieldText = textField.text else { return }
        formField?.updateValue(textFieldText)
        configureTextFieldRightView(shouldDisplay: textFieldText.isEmpty)
    }
    
    private func configureTextFieldRightView(shouldDisplay: Bool) {
        if formField?.fieldType == .paymentCardNumber && shouldDisplay {
            textFieldRightView.isHidden = false
        } else {
            textFieldRightView.isHidden = true
        }
    }
    
    @objc func handleCellTap() {
        textField.becomeFirstResponder()
    }
    
    @objc func accessoryDoneTouchUpInside() {
        if let multipleChoiceInput = textField.inputView as? FormMultipleChoiceInput, let textFieldIsEmpty = textField.text?.isEmpty {
            multipleChoiceInputDidUpdate(newValue: textFieldIsEmpty ? "" : multipleChoiceInput.fullContentString, backingData: multipleChoiceInput.backingData)
        }
        
        textField.resignFirstResponder()
        textFieldDidEndEditing(textField)
    }
    
    @objc func handleScanButtonTap() {
        delegate?.formCollectionViewCellDidReceivePaymentScannerButtonTap(self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // In order to allow a field to appear disabled, but allow the clear button to still be functional, we cannot make the textfield disabled
        // So we must block the editing instead, which allows the clear button to still work
        return formField?.isReadOnly == false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        configureTextFieldRightView(shouldDisplay: true)
        return true
    }
    
    private func configureStateForFieldValidity(_ field: FormField) {
        let textfieldIsEmpty = textField.text?.isEmpty ?? false

        if !field.isValid() && !textfieldIsEmpty {
            validationLabel.isHidden = false
        } else {
            validationLabel.isHidden = true
        }
        
        validationLabel.text = field.validationErrorMessage != nil ? field.validationErrorMessage : "Invalid input"
    }
}

extension FormCollectionViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formField?.textField(textField, shouldChangeInRange: range, newValue: string) ?? false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let field = formField else { return }
        configureStateForFieldValidity(field)
        field.fieldWasExited()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let multipleChoiceInput = textField.inputView as? FormMultipleChoiceInput {
            textField.text = (pickerSelectedChoice?.isEmpty ?? false) ? multipleChoiceInput.fullContentString : pickerSelectedChoice
        }

        self.delegate?.formCollectionViewCell(self, didSelectField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension FormCollectionViewCell: FormMultipleChoiceInputDelegate {
    func multipleChoiceSeparatorForMultiValues() -> String? {
        return "/"
    }
    
    func multipleChoiceInputDidUpdate(newValue: String?, backingData: [Int]?) {
        pickerSelectedChoice = newValue
        formField?.updateValue(newValue)
        textField.text = newValue
        if let options = backingData { formField?.pickerDidSelect(options) }
    }
}

fileprivate extension Selector {
    static let textFieldUpdated = #selector(FormCollectionViewCell.textFieldUpdated)
    static let accessoryDoneTouchUpInside = #selector(FormCollectionViewCell.accessoryDoneTouchUpInside)
    static let handleScanButtonTap = #selector(FormCollectionViewCell.handleScanButtonTap)
    static let handleCellTap = #selector(FormCollectionViewCell.handleCellTap)
}
