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
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField)
    func formCollectionViewCellDidReceivePaymentScannerButtonTap(_ cell: FormCollectionViewCell)
}

extension FormCollectionViewCellDelegate {
    func formCollectionViewCellDidReceivePaymentScannerButtonTap(_ cell: FormCollectionViewCell) {}
}

class FormCollectionViewCell: UICollectionViewCell {
    private weak var delegate: FormCollectionViewCellDelegate?
    // MARK: - Helpers
    
    private enum Constants {
        static let titleLabelHeight: CGFloat = 20.0
        static let textFieldHeight: CGFloat = 24.0
        static let validationLabelHeight: CGFloat = 20.0
        static let cornerRadius: CGFloat = 10
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
        stackView.backgroundColor = .clear
        stackView.layer.cornerCurve = .continuous
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.clipsToBounds = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: .handleCellTap)
        stackView.addGestureRecognizer(gestureRecognizer)
        stackView.isUserInteractionEnabled = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
//    /// Contains title label, text field, camera icon and validation icon
//    private lazy var fieldContentHStack: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [fieldLabelsVStack])
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .horizontal
//        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
//        stackView.isLayoutMarginsRelativeArrangement = true
//        return stackView
//    }()
//
//    /// The view that contains the title label and text field
//    private lazy var fieldLabelsVStack: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [textFieldHStack])
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .vertical
//        return stackView
//    }()
    
    /// The view that contains the text field, camera icon and the validation icon
    private lazy var textFieldHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, textFieldRightView, validationIconImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        contentView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.heightAnchor.constraint(equalToConstant: Constants.titleLabelHeight).isActive = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .systemFont(ofSize: 14, weight: .regular)
        field.delegate = self
        field.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight).isActive = true
        field.addTarget(self, action: .textFieldUpdated, for: .editingChanged)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        field.smartQuotesType = .no // This stops the "smart" apostrophe setting. The default breaks field regex validation
        return field
    }()
    
    lazy var validationIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon-check", in: .module, with: nil))
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        imageView.transform = CGAffineTransform(translationX: -4, y: 0)
        imageView.isHidden = true
        return imageView
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
        view.backgroundColor = .quaternarySystemFill
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.cornerCurve = .continuous
        view.addSubview(validationView)
        view.clipsToBounds = true
        return view
    }()
    
    /// The bar that represents the field's state using colour
    private lazy var validationView: UIView = {
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
//        label.leftInset = 20
        label.font = .systemFont(ofSize: 13, weight: .light)
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
    
    private var preferredWidth: CGFloat = 300 // This has to be a non zero value, chose 300 because of the movie 300.
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutAttributes.frame.size.width = preferredWidth
        layoutAttributes.bounds.size.height = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        return layoutAttributes
    }
    
    private weak var formField: FormField?
    private var pickerSelectedChoice: String?
    private var themeConfig: BinkThemeConfiguration?
    
    // MARK: - Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
            validationView.leftAnchor.constraint(equalTo: stackBackgroundView.leftAnchor),
            validationView.rightAnchor.constraint(equalTo: stackBackgroundView.rightAnchor),
            validationView.bottomAnchor.constraint(equalTo: stackBackgroundView.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods

    func configure(with field: FormField, themeConfig: BinkThemeConfiguration? = nil, delegate: FormCollectionViewCellDelegate?) {
        self.themeConfig = themeConfig
        textField.text = field.forcedValue
        textField.keyboardType = field.fieldType.keyboardType()
        textField.autocorrectionType = field.fieldType.autoCorrection()
        textField.autocapitalizationType = field.fieldType.capitalization()
        textField.clearButtonMode = .whileEditing
        textField.accessibilityIdentifier = field.title
        formField = field
        
        // Remove when we drop iOS 13 - add validation view to fieldContainerVStack
        fieldContainerVStack.insertSubview(stackBackgroundView, at: 0)
        stackBackgroundView.pin(to: fieldContainerVStack)
        
        configureTextFieldRightView(shouldDisplay: formField?.value == nil)
//        validationLabel.isHidden = textField.text?.isEmpty == true ? true : field.isValid()

        textField.inputAccessoryView = inputAccessory
        
        if case let .expiry(months, years) = field.fieldType {
            textField.inputView = FormMultipleChoiceInput(with: [months, years], delegate: self)
        } else {
            textField.inputView = nil
        }
        
        self.delegate = delegate
//        configureStateForFieldValidity(field)
        configureTheme(field)
    }
    
    func setWidth(_ width: CGFloat) {
        preferredWidth = width
    }
    
    private func configureTheme(_ field: FormField) {
        let config = themeConfig ?? BinkThemeConfiguration()
        titleLabel.textColor = config.titleTextColor
        textField.textColor = config.textfieldTextColor
        
        switch config.fieldPromptStyle {
        case .header:
            titleLabel.text = field.title
        case .inline:
            textField.attributedPlaceholder = NSAttributedString(string: field.title, attributes: [.foregroundColor : config.titleTextColor.withAlphaComponent(0.5)])
                
        }
        
        switch config.fieldBorderStyle {
        case .box:
            fieldContainerVStack.layer.borderColor = config.fieldBorderColor.cgColor
            fieldContainerVStack.layer.borderWidth = config.fieldBorderWidth
        case .underline:
            validationView.isHidden = false
            validationView.backgroundColor = config.fieldBorderColor
            validationView.heightAnchor.constraint(equalToConstant: config.fieldBorderWidth).isActive = true
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
    
    enum ControlState {
        case inactive, active, valid, invalid
    }
    
    private func configureStateForFieldValidity(_ field: FormField) {
//        let textfieldIsEmpty = textField.text?.isEmpty ?? false

//        if field.isValid() && !textfieldIsEmpty {
//            setState(.valid)
//        } else if !field.isValid() && !textfieldIsEmpty {
//            setState(.invalid)
//        } else {
//            setState(.inactive)
//        }
    }
    
    func setState(_ state: ControlState) {
        var validationLabelSpacing: CGFloat = validationLabel.isHidden ? 0 : 4
        var validationIconHidden = true

        switch state {
        case .inactive:
            validationView.backgroundColor = .clear
            validationLabel.isHidden = true
            validationLabelSpacing = 0
        case .active:
            validationView.backgroundColor = .systemBlue
        case .valid:
            validationView.backgroundColor = .okGreen
            validationIconHidden = false
            validationLabelSpacing = 0
            validationLabel.isHidden = true
        case .invalid:
            validationView.backgroundColor = .systemRed
            validationLabelSpacing = 4
            validationLabel.isHidden = false
        }

        guard let field = formField else { return }
        validationLabel.text = field.validationErrorMessage != nil ? field.validationErrorMessage : "Invalid input"
        validationIconImageView.isHidden = validationIconHidden
        containerStack.setCustomSpacing(validationLabelSpacing, after: fieldContainerVStack)
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
        
//        setState(.active)
        
        self.delegate?.formCollectionViewCell(self, didSelectField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.formCollectionViewCell(self, shouldResignTextField: textField)
        return true
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
