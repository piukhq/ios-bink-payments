//
//  BinkPaymentsManager.swift
//  
//
//  Created by Ricardo Silva on 13/09/2022.
//

import AlamofireNetworkActivityLogger
import UIKit

public protocol BinkPaymentsManagerDelegate: AnyObject {
    func apiResponseNotification(_ notification: NSNotification)
}

public class BinkPaymentsManager: NSObject, UINavigationControllerDelegate {
    public static let shared = BinkPaymentsManager()
    public var themeConfig = BinkThemeConfiguration()
    public var loyaltyPlan: LoyaltyPlanModel?
    private let wallet = Wallet()
    let apiClient = APIClient()
    
    /// Required variables on initialization
    private var planID: String!
    var email: String!
    var token: String!
    var refreshToken: String!
    var environmentKey: String!
    var isDebug: Bool!
    var config: Configuration!

    public weak var delegate: BinkPaymentsManagerDelegate?
    
    private var currentViewController: UIViewController? {
        return UIViewController.topMostViewController()
    }

    private override init() {}
    
    public var loyaltyCard: LoyaltyCardModel? {
        initializationAssertion()
        return wallet.loyaltyCards?.first
    }
    
    
    // MARK: - Public Methods

    public func configure(environmentKey: String!, configuration: Configuration, email: String!, isDebug: Bool) {
        assert(!environmentKey.isEmpty, "Bink SDK Error - environment key missing")
        NotificationCenter.default.addObserver(self, selector: #selector(apiResponseNotification(_:)), name: .apiResponse, object: nil)

        self.email = email
        self.environmentKey = environmentKey
        self.isDebug = isDebug
        self.planID = isDebug ? configuration.testLoyaltyPlanID : configuration.productionLoyaltyPlanID
        self.config = configuration
        
        print("Bink Payments SDK Initialised")
        
        #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        if !isDebug {
            print("Warning: You are running a DEBUG session but not in Test Mode!")
        }
        #endif
    }
    
    public func setToken(token: String, refreshToken: String) {
        self.token = token
        self.refreshToken = refreshToken
        
        wallet.fetch()
        
        wallet.getLoyaltyPlan(for: planID) { result in
            switch result {
            case .success(let loyaltyPlan):
                self.loyaltyPlan = loyaltyPlan
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc public func apiResponseNotification(_ notification: NSNotification) {
        delegate?.apiResponseNotification(notification)
    }
    
    public func launchScanner(fullScreen: Bool = false) {
        initializationAssertion()
        if #available(iOS 13, *) {
            let binkScannerViewController = BinkScannerViewController(themeConfig: themeConfig, visionUtility: VisionUtility())
            binkScannerViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: binkScannerViewController)

            if fullScreen {
                navigationController.modalPresentationStyle = .fullScreen
            }
            
            configureScannerViewController(with: navigationController)
        }
    }
    
    public func launchDebugScreen(paymentCard: PaymentAccountCreateModel) {
        initializationAssertion()
        let debugScreen = DebugViewController(paymentCard: paymentCard)
        currentViewController?.present(debugScreen, animated: true)
    }
    
    public func launchAddPaymentCardScreen(_ paymentCard: PaymentAccountCreateModel? = nil) {
        initializationAssertion()
        let addPaymentCardViewController = AddPaymentCardViewController(viewModel: AddPaymentCardViewModel(paymentCard: paymentCard), themeConfig: themeConfig)
        currentViewController?.show(addPaymentCardViewController, sender: nil)
    }
    
    public func paymentAccount(from id: Int) -> PaymentAccountResponseModel? {
        initializationAssertion()
        return wallet.paymentAccounts?.first(where: { $0.apiId == id })
    }
    
    public func pllStatus(for loyaltyCard: LoyaltyCardModel, refreshedLinkedState: @escaping (LoyaltyCardPLLState) -> Void ) -> LoyaltyCardPLLState {
        initializationAssertion()
        let pllState = wallet.configurePLLState(for: loyaltyCard)
        
        wallet.fetch { [weak self] in
            if let refreshedState = self?.wallet.configurePLLState(for: loyaltyCard) {
                refreshedLinkedState(refreshedState)
            }
        }
        
        return pllState
    }
    
//    public func pllStatus(for paymentAccount: PaymentAccountResponseModel, refreshedLinkedState: @escaping (PaymentAccountPLLState) -> Void ) -> PaymentAccountPLLState {
//        initializationAssertion()
//        let pllState = wallet.configurePLLState(for: paymentAccount)
//
//        wallet.fetch { [weak self] in
//            if let refreshedState = self?.wallet.configurePLLState(for: paymentAccount) {
//                refreshedLinkedState(refreshedState)
//            }
//        }
//
//        return pllState
//    }
    
    public func set(loyaltyId: LoyaltyIdType, accountId: String, completion: (() -> Void)? = nil) {
        initializationAssertion()
        guard !accountId.isEmpty else { return }
        let account = configureAccountModel(loyaltyId: loyaltyId, accountId: accountId)
        let model = LoyaltyCardAddTrustedRequestModel(loyaltyPlanID: Int(planID) ?? 0, account: account)
        
        wallet.fetch { [weak self] in
            guard let self = self, let loyaltyCards = self.wallet.loyaltyCards else { return }
            
            self.wallet.addLoyaltyCardTrusted(withRequestModel: model) { result, _  in
                switch result {
                case .success(let response):
                    if self.isDebug { print(response) }
                    
                    loyaltyCards.forEach { loyaltyCard in
                        if loyaltyCard.apiId == response.id {
                            print("Loyalty identity already exists in wallet")
                        } else {
                            /// Delete all other cards in wallet
                            self.wallet.deleteLoyaltyCard(id: String(loyaltyCard.apiId ?? 0))
                        }
                    }
                    
                    self.wallet.fetch() {
                        completion?()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    public func replace(loyaltyId: LoyaltyIdType, accountId: String, completion: (() -> Void)? = nil) {
        initializationAssertion()
        guard !accountId.isEmpty, let loyaltyCardId = loyaltyCard?.apiId else { return }
        let account = configureAccountModel(loyaltyId: loyaltyId, accountId: accountId)
        let model = LoyaltyCardUpdateTrustedRequestModel(account: account)
         
        wallet.updateLoyaltyCardTrusted(forLoyaltyCardId: loyaltyCardId, model: model) { [weak self] result, _ in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if self.isDebug { print(response) }
                self.wallet.fetch() {
                    completion?()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func configureAccountModel(loyaltyId: LoyaltyIdType, accountId: String) -> Account {
        let credentials = Credential(credentialSlug: loyaltyId.slug, value: loyaltyId.value)
        var addFields: AddFields?
        var authoriseFields: AuthoriseFields?
        
        if config.trustedCredentialType == .add {
            addFields = AddFields(credentials: [credentials])
        } else {
            authoriseFields = AuthoriseFields(credentials: [credentials])
        }
        
        let merchantFields = MerchantFields(accountID: accountId)
        return Account(addFields: addFields, authoriseFields: authoriseFields, merchantFields: merchantFields)
    }
    
    // MARK: - Private & Internal Methods
    
    @available(iOS 13.0, *)
    func launchScanner(delegate: BinkScannerViewControllerDelegate) {
        let binkScannerViewController = BinkScannerViewController(themeConfig: themeConfig, visionUtility: VisionUtility())
        binkScannerViewController.delegate = delegate
        let navigationController = UINavigationController(rootViewController: binkScannerViewController)
        configureScannerViewController(with: navigationController)
    }
    
    private func configureScannerViewController(with navigationController: UINavigationController) {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.setBackIndicatorImage(themeConfig.backIndicatorImage, transitionMaskImage: themeConfig.backIndicatorImage)
            appearance.buttonAppearance.normal.titleTextAttributes = [.font: themeConfig.navigationBackButtonTitleFont, .foregroundColor: themeConfig.navigationBarTintColor]

            navigationController.navigationBar.tintColor = themeConfig.navigationBarTintColor
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance

            navigationController.navigationBar.standardAppearance.backgroundEffect = themeConfig.navigationBarBackgroundEffect
            navigationController.navigationBar.standardAppearance.backgroundColor = themeConfig.primaryColor.withAlphaComponent(themeConfig.navigationBarBackgroundAlpha)
            navigationController.navigationBar.scrollEdgeAppearance?.backgroundEffect = themeConfig.navigationBarBackgroundEffect
            navigationController.navigationBar.scrollEdgeAppearance?.backgroundColor = themeConfig.primaryColor.withAlphaComponent(themeConfig.navigationBarBackgroundAlpha)
            
            currentViewController?.present(navigationController, animated: true)
        }
    }
    
    private func initializationAssertion() {
        assert(token != nil && refreshToken != nil && environmentKey != nil && email != nil && planID != nil, "Bink Payments SDK Error - Please ensure the SDK has been configured correctly")
    }
}


// MARK: - Extensions

@available(iOS 13.0, *)
extension BinkPaymentsManager: BinkScannerViewControllerDelegate {
    func binkScannerViewControllerShouldEnterManually(_ viewController: BinkScannerViewController, completion: (() -> Void)?) {
        launchAddPaymentCardScreen()
    }
    
    func binkScannerViewController(_ viewController: BinkScannerViewController, didScan paymentCard: PaymentAccountCreateModel) {
        launchAddPaymentCardScreen(paymentCard)
    }
}
