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

/// This is the class that exposes all the necessary functionality for payments
public class BinkPaymentsManager: NSObject, UINavigationControllerDelegate {
    /// shared variable
    public static let shared = BinkPaymentsManager()
    
    /// default theme configuration. Can be overriden with a custom BinkThemeConfiguration
    public var themeConfig = BinkThemeConfiguration()
    
    /// struct with the loyalty plan info
    public var loyaltyPlan: LoyaltyPlanModel?
    
    private let wallet = Wallet()
    private var email: String!
    private var planID: String!
    var token: String!
    var refreshToken: String!
    var environmentKey: String!
    var isDebug: Bool!
    
    public weak var delegate: BinkPaymentsManagerDelegate?
    
    var config: Configuration? {
        if let data = try? Data(contentsOf: plistURL) {
            if let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] {
                return Configuration(
                    testLoyaltyPlanID: plist["testPlanID"] ?? "",
                    productionLoyaltyPlanID: plist["productionPlanID"] ?? "",
                    trustedCredentialType: Configuration.TrustedCredentialType(rawValue: plist["trustedCredentialType"] ?? "") ?? .add)
            }
            
        }
        return nil
    }
    
    private var plistURL: URL {
        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentDirectoryURL.appendingPathComponent("config.plist")
    }
    
    private var currentViewController: UIViewController? {
        return UIViewController.topMostViewController()
    }

    private override init() {}
    
    
    // MARK: - Public Methods

    /// configure is the starting point of the SDK
    ///
    /// Pass the unique parameters so that the SDK will initialize properly.
    ///
    /// ```swift
    /// let config = Configuration(testLoyaltyPlanID: "1", productionLoyaltyPlanID: "1", trustedCredentialType: .authorise)
    /// paymentsManager.configure(
    /// token: "token",
    /// refreshToken: 'refreshToken',
    /// environmentKey: "envKey",
    /// configuration: config,
    /// email: "email@mail.com",
    /// isDebug: true)
    /// ```
    ///
    /// - Parameters:
    ///   - token: Required - token given via the retailer's API.
    ///   - refreshToken: Required - refresh token given via the retailer's API.
    ///   - environmentKey: Required - unique key
    ///   - configuration: Required - instanciate an object of type Configuration.
    ///   - email: Required - the user's email
    ///   - isDebug: when true, debug info will be logged into the console.
    public func configure(token: String!, refreshToken: String!, environmentKey: String!, configuration: Configuration, email: String!, isDebug: Bool) {
        assert(!token.isEmpty && !refreshToken.isEmpty && !environmentKey.isEmpty, "Bink Payments SDK Error - Not Initialised due to missing token/environment key")
        assert(!email.isEmpty, "Bink Payments SDK Error - Not Initialised due to missing email address")
        NotificationCenter.default.addObserver(self, selector: #selector(apiResponseNotification(_:)), name: .apiResponse, object: nil)
        
        self.email = email
        
        if isDebug {
            self.token = token
            self.refreshToken = refreshToken
        } else {
            self.token = TokenKeychainManager.getToken(service: .accessTokenService) ?? token
            self.refreshToken = TokenKeychainManager.getToken(service: .refreshTokenService) ?? refreshToken
        }

        self.environmentKey = environmentKey
        self.isDebug = isDebug
        
        let configDictionary: [String: String] = [
            "testPlanID" : configuration.testLoyaltyPlanID,
            "productionPlanID": configuration.productionLoyaltyPlanID,
            "trustedCredentialType": configuration.trustedCredentialType.rawValue
        ]
        
        let plistData = try? PropertyListSerialization.data(fromPropertyList: configDictionary, format: .xml, options: 0)
        try? plistData?.write(to: plistURL)
        
        print("Bink Payments SDK Initialised")
        
        #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        if !isDebug {
            print("Warning: You are running a DEBUG session but not in Test Mode!")
        }
        #endif
        
        wallet.fetch()
        
        planID = isDebug ? configuration.testLoyaltyPlanID : configuration.productionLoyaltyPlanID
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
    
    
    /// Method that will create and launch a scanner view controller
    /// - Parameter fullScreen: set to true for full screen presentation
    @available(iOS 13.0, *)
    public func launchScanner(fullScreen: Bool = false) {
        let binkScannerViewController = BinkScannerViewController(themeConfig: themeConfig, visionUtility: VisionUtility())
        binkScannerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: binkScannerViewController)

        if fullScreen {
            navigationController.modalPresentationStyle = .fullScreen
        }
        
        configureScannerViewController(with: navigationController)
    }
    
    /// Helper method to launch a debug screen displaying card information
    ///
    /// - Parameter paymentCard: model with information related to a payment card
    public func launchDebugScreen(paymentCard: PaymentAccountCreateModel) {
        let debugScreen = DebugViewController(paymentCard: paymentCard)
        currentViewController?.present(debugScreen, animated: true)
    }
    
    /// This method creates a screen to register a payment card. If the card has been scanned a struct of type
    /// `PaymentAccountCreateModel` with the payment card details will be passed in and the fields will be auto filled.
    /// If no parameter is passed the user can manually type the card details
    /// - Parameter paymentCard: Optional - model with inofrmation related to a payment card
    public func launchAddPaymentCardScreen(_ paymentCard: PaymentAccountCreateModel? = nil) {
        let addPaymentCardViewController = AddPaymentCardViewController(viewModel: AddPaymentCardViewModel(paymentCard: paymentCard), themeConfig: themeConfig)
        currentViewController?.show(addPaymentCardViewController, sender: nil)
    }
    
    /// The loyalty card that currently exists on the user's wallet
    /// - Returns: Loyalty card information of the type `LoyaltyCardModel`
    public func loyaltyCard() -> LoyaltyCardModel? {
        return wallet.loyaltyCard
    }
    
    /// Method to retrieve the payment account from the suer's wallet
    /// - Parameter id: account id
    /// - Returns: model with payment account info including PLL info
    public func paymentAccount(from id: Int) -> PaymentAccountResponseModel? {
        return wallet.paymentAccounts?.first(where: { $0.apiId == id })
    }
    
    /// Method that returns the linked state of a loyalty card
    /// - Parameters:
    ///   - loyaltyCard: loyalty card model which we want to check the current state
    ///   - refreshedLinkedState: escaping closure reurning a LoyaltyCardPLLState model
    /// - Returns: LoyaltyCardPLLState model. 
    public func pllStatus(for loyaltyCard: LoyaltyCardModel, refreshedLinkedState: @escaping (LoyaltyCardPLLState) -> Void ) -> LoyaltyCardPLLState {
        let pllState = wallet.configurePLLState(for: loyaltyCard)
        
        wallet.fetch { [weak self] in
            if let refreshedState = self?.wallet.configurePLLState(for: loyaltyCard) {
                refreshedLinkedState(refreshedState)
            }
        }
        
        return pllState
    }
    
    /// Method that returns the linked state of a payment card
    /// - Parameters:
    ///   - paymentAccount: payment card which we want to check the current state
    ///   - refreshedLinkedState: escaping closure reurning a PaymentAccountPLLState model
    /// - Returns: PaymentAccountPLLState model
    public func pllStatus(for paymentAccount: PaymentAccountResponseModel, refreshedLinkedState: @escaping (PaymentAccountPLLState) -> Void ) -> PaymentAccountPLLState {
        let pllState = wallet.configurePLLState(for: paymentAccount)
        
        wallet.fetch { [weak self] in
            if let refreshedState = self?.wallet.configurePLLState(for: paymentAccount) {
                refreshedLinkedState(refreshedState)
            }
        }
        
        return pllState
    }
    
    /// Method that adds the loyalty card in the wallet to a trusted channel
    /// - Parameters:
    ///   - loyaltyIdentity: unique customer loyalty card
    ///   - completion: optional closure
    public func set(loyaltyIdentity: String, completion: (() -> Void)? = nil) {
        guard !loyaltyIdentity.isEmpty else { return }
        
        let model = LoyaltyCardAddTrustedRequestModel(loyaltyPlanID: Int(planID) ?? 0, account: Account(authoriseFields: AuthoriseFields(credentials: [Credential(credentialSlug: "email", value: email)]), merchantFields: MerchantFields(accountID: loyaltyIdentity)))
        wallet.addLoyaltyCardTrusted(withRequestModel: model) { [weak self] result, _  in
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
    
    /// Method that updates the loyalty identity of a of a card in the tursted channel
    /// - Parameters:
    ///   - loyaltyIdentity: unique customer loyalty card
    ///   - completion: optional closure
    public func replace(loyaltyIdentity: String, completion: (() -> Void)? = nil) {
        guard !loyaltyIdentity.isEmpty else { return }
        guard let loyaltyCardId = wallet.loyaltyCard?.apiId else { return }
        
        let model = LoyaltyCardUpdateTrustedRequestModel(account: Account(authoriseFields: AuthoriseFields(credentials: [Credential(credentialSlug: "email", value: email)]), merchantFields: MerchantFields(accountID: loyaltyIdentity)))
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
