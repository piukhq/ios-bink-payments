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

    public func configure(token: String!, refreshToken: String!, environmentKey: String!, configuration: Configuration, email: String!, isDebug: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(apiResponseNotification(_:)), name: .apiResponse, object: nil)
                
        if isDebug {
            self.token = token
            self.refreshToken = refreshToken
        } else {
            self.token = TokenKeychainManager.getToken(service: .accessTokenService) ?? token
            self.refreshToken = TokenKeychainManager.getToken(service: .refreshTokenService) ?? refreshToken
        }

        self.email = email
        self.environmentKey = environmentKey
        self.isDebug = isDebug
        initializationAssertion()

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
    
    public func loyaltyCard() -> LoyaltyCardModel? {
        initializationAssertion()
        return wallet.loyaltyCard
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
    
    public func pllStatus(for paymentAccount: PaymentAccountResponseModel, refreshedLinkedState: @escaping (PaymentAccountPLLState) -> Void ) -> PaymentAccountPLLState {
        initializationAssertion()
        let pllState = wallet.configurePLLState(for: paymentAccount)
        
        wallet.fetch { [weak self] in
            if let refreshedState = self?.wallet.configurePLLState(for: paymentAccount) {
                refreshedLinkedState(refreshedState)
            }
        }
        
        return pllState
    }
    
    public func set(loyaltyIdentity: String, completion: (() -> Void)? = nil) {
        initializationAssertion()
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
    
    public func replace(loyaltyIdentity: String, completion: (() -> Void)? = nil) {
        initializationAssertion()
        guard !loyaltyIdentity.isEmpty, let loyaltyCardId = wallet.loyaltyCard?.apiId else { return }
        
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
    
    private func initializationAssertion() {
        assert((token != nil) && !refreshToken.isEmpty && !environmentKey.isEmpty && !email.isEmpty, "Bink Payments SDK Error - incomplete initialization due to missing environment variables")
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
