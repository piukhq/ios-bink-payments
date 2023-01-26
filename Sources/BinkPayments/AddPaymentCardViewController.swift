//
//  AddPaymentCardViewController.swift
//  
//
//  Created by Sean Williams on 14/10/2022.
//

import Combine
import UIKit

class AddPaymentCardViewController: UIViewController {
    // MARK: - Helpers
    
    private enum Constants {
        static let horizontalInset: CGFloat = 20
        static let bottomInset: CGFloat = 150.0
        static let postCollectionViewPadding: CGFloat = 25.0
        static let preCollectionViewPadding: CGFloat = 10.0
        static let cellErrorLabelSafeSpacing: CGFloat = 60.0
        static let offsetPadding: CGFloat = 30.0
        static let cardHeight: CGFloat = 120.0
        static let buttonCornerRadius: CGFloat = 25
        static let buttonSpacing: CGFloat = 25
        static let buttonHeight: CGFloat = 50
        static let bottomPadding: CGFloat = 16
        static let bottomSafePadding: CGFloat = {
            let window = UIApplication.shared.getKeyWindow
            let safeAreaBottom = window?.safeAreaInsets.bottom ?? 0
            return bottomPadding + safeAreaBottom
        }()
    }
    
    // MARK: - Properties
    
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [collectionView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: Constants.bottomInset, right: 0)
        stackView.customPadding(Constants.postCollectionViewPadding, after: collectionView)
        stackView.customPadding(Constants.preCollectionViewPadding, before: collectionView)
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var collectionView: NestedCollectionView = {
        let collectionView = NestedCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(FormCollectionViewCell.self)
        return collectionView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemPink
        button.setTitle("Add Card", for: .normal)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        if #available(iOS 13.0, *) {
            button.layer.cornerCurve = .continuous
        }
        if #available(iOS 13.0, *) {
            button.tintColor = .white
        } else {
            button.tintColor = .white
        }
        button.isEnabled = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let image = UIImage(named: "close", in: .module, compatibleWith: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(close))
        return button
    }()
    
    private lazy var card: PaymentCardCollectionViewCell = {
        let cell: PaymentCardCollectionViewCell = .fromNib()
        return cell
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    
    //private var subscriptions = Set<AnyCancellable>()
    private var hasSetupCell = false
    private var selectedCellYOrigin: CGFloat = 0.0
    private var selectedCellHeight: CGFloat = 0.0
    private var themeConfig: BinkThemeConfiguration
    public var viewModel: AddPaymentCardViewModel
    
    init(viewModel: AddPaymentCardViewModel, themeConfig: BinkThemeConfiguration) {
        self.viewModel = viewModel
        self.themeConfig = themeConfig
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        configureTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        viewModel.initialSetup(formDelegate: self)
        
        let switchView = BinkSwitchView(themeConfig: themeConfig, text: "Switch me please")
        stackScrollView.add(arrangedSubview: switchView)
        
        let checkbox = CheckboxView(checked: true, themeConfig: themeConfig, title: "Check this")
        stackScrollView.add(arrangedSubview: checkbox)
    }
    
    private func configureTheme() {
        stackScrollView.backgroundColor = themeConfig.backgroundColor
        
        let attributedText = NSAttributedString(string: themeConfig.navigationTitle, attributes: [.font: themeConfig.navigationTitleFont, .foregroundColor: themeConfig.navigationBarTitleTextColor])
        let label = UILabel()
        label.attributedText = attributedText
        navigationItem.titleView = label
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.bottomSafePadding),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonSpacing),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonSpacing),
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
        
        stackScrollView.insert(arrangedSubview: card, atIndex: 0, customSpacing: 20)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: Constants.cardHeight),
            card.widthAnchor.constraint(equalTo: collectionView.widthAnchor)
        ])
        
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    @objc func addButtonTapped() {
        addButton.isEnabled = false
        viewModel.addPaymentCard { [weak self] in
            let ac = UIAlertController(title: "Success", message: "Payment card successfully added to Bink", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self?.dismiss(animated: true)
            }
            ac.addAction(okAction)
            self?.navigationController?.present(ac, animated: true)
        } onError: { [weak self] in
            let ac = UIAlertController(title: "Error Adding Card", message: "There was a problem adding your payment card. Please try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            ac.addAction(okAction)
            self?.navigationController?.present(ac, animated: true)
            self?.addButton.isEnabled = true
        }
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }

            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                let visibleOffset = UIScreen.main.bounds.height - keyboardHeight
                let cellVisibleOffset = self.selectedCellYOrigin + self.selectedCellHeight

                if cellVisibleOffset > visibleOffset {
                    let actualOffset = self.stackScrollView.contentOffset.y
                    let neededOffset = CGPoint(x: 0, y: Constants.offsetPadding + actualOffset + cellVisibleOffset - visibleOffset)
                    self.stackScrollView.setContentOffset(neededOffset, animated: true)

                    /// From iOS 14, we are seeing this method being called more often than we would like due to a notification trigger not only when the cell's text field is selected, but when typed into.
                    /// We are resetting these values so that the existing behaviour will still work, whereby these values are updated from delegate methods when they should be, but when the notification is
                    /// called from text input, these won't be updated and therefore will remain as 0.0, and won't fall into this if statement and won't update the content offset of the stack scroll view.
                    self.selectedCellYOrigin = 0.0
                    self.selectedCellHeight = 0.0
                }
            }
        }
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}

extension AddPaymentCardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? FormCollectionViewCell else { return }
        cell.setWidth(collectionView.frame.size.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.fields.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FormCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
        let field = viewModel.fields[indexPath.item]
        cell.configure(with: field, themeConfig: themeConfig, delegate: self)
        return cell
    }
}

extension AddPaymentCardViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {
        let cellOrigin = collectionView.convert(cell.frame.origin, to: view)
        self.selectedCellYOrigin = cellOrigin.y
        selectedCellHeight = cell.frame.size.height + Constants.cellErrorLabelSafeSpacing
    }
    
    func formCollectionViewCellDidReceivePaymentScannerButtonTap(_ cell: FormCollectionViewCell) {
        if #available(iOS 13.0, *) {
            BinkPaymentsManager.shared.launchScanner(delegate: self)
        }
    }
}

@available(iOS 13.0, *)
extension AddPaymentCardViewController: BinkScannerViewControllerDelegate {
    func binkScannerViewControllerShouldEnterManually(_ viewController: BinkPayments.BinkScannerViewController, completion: (() -> Void)?) {
        dismiss(animated: true)
    }
    
    func binkScannerViewController(_ viewController: BinkScannerViewController, didScan paymentCard: PaymentAccountCreateModel) {
        dismiss(animated: true) { [weak self] in
            paymentCard.month = paymentCard.month ?? self?.viewModel.paymentCard.month
            paymentCard.year = paymentCard.year ?? self?.viewModel.paymentCard.year
            paymentCard.nameOnCard = paymentCard.nameOnCard ?? self?.viewModel.paymentCard.nameOnCard
            self?.viewModel.paymentCard = paymentCard
            self?.viewModel.refreshDataSource()
        }
    }
}

extension AddPaymentCardViewController: PaymentCardFormDelegate {
    func updateOnCardChanges(paymentCard: PaymentAccountCreateModel) {
        card.configureWithAddViewModel(paymentCard)
    }
    
    func updatedOnFormValidation(valid: Bool) {
        addButton.isEnabled = valid
        collectionView.collectionViewLayout.invalidateLayout()
        stackScrollView.contentInset.bottom = Constants.bottomInset
    }
    
    func refreshForm() {
        collectionView.reloadData()
    }
}
