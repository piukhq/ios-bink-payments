//
//  BinkPaymentsManager.swift
//  
//
//  Created by Ricardo Silva on 13/09/2022.
//

import AlamofireNetworkActivityLogger
import UIKit

public class BinkPaymentsManager: NSObject, UINavigationControllerDelegate {
    public static let shared = BinkPaymentsManager()
    private var wallet = Wallet()
    public var themeConfig = BinkThemeConfiguration()
    var token: String!
    var environmentKey: String!
    var isDebug: Bool!
    
    private var currentViewController: UIViewController? {
        return UIViewController.topMostViewController()
    }

    private override init() {}
    
    public func configure(token: String!, environmentKey: String!, isDebug: Bool) {
        assert(!token.isEmpty && !environmentKey.isEmpty, "Bink Payments SDK Error - Not Initialised due to missing token/environment key")
        
        self.token = token
        self.environmentKey = environmentKey
        self.isDebug = isDebug
        print("Bink Payments SDK Initialised")
        
        #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        if !isDebug {
            print("Warning: You are running a DEBUG session but not in Test Mode!")
        }
        #endif
        
        wallet.fetch()
    }
    
    public func launchScanner(delegate: BinkScannerViewControllerDelegate) {
        let binkScannerViewController = BinkScannerViewController(themeConfig: themeConfig)
        binkScannerViewController.delegate = delegate
        let navigationController = UINavigationController(rootViewController: binkScannerViewController)

//        navigationController.modalPresentationStyle = .fullScreen
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = themeConfig.primaryColor
        appearance.titleTextAttributes = [.foregroundColor: themeConfig.navigationBarTintColor]
        appearance.setBackIndicatorImage(themeConfig.backIndicatorImage, transitionMaskImage: themeConfig.backIndicatorImage)
        navigationController.navigationBar.tintColor = themeConfig.navigationBarTintColor
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        currentViewController?.present(navigationController, animated: true)
    }
    
    public func launchDebugScreen(paymentCard: PaymentAccountCreateModel) {
        let debugScreen = DebugViewController(paymentCard: paymentCard)
        currentViewController?.present(debugScreen, animated: true)
    }
    
    public func launchAddPaymentCardScreen(_ paymentCard: PaymentAccountCreateModel? = nil) {
        let addPaymentCardViewController = AddPaymentCardViewController(viewModel: AddPaymentCardViewModel(paymentCard: paymentCard), themeConfig: themeConfig)
        currentViewController?.show(addPaymentCardViewController, sender: nil)
    }
    
    public func loyaltyCard(from id: Int) -> LoyaltyCardModel? {
        return wallet.loyaltyCards?.first(where: { $0.apiId == id })
    }
    
    public func paymentAccount(from id: Int) -> PaymentAccountResponseModel? {
        return wallet.paymentAccounts?.first(where: { $0.apiId == id })
    }
    
    public func pllStatus(for loyaltyCard: LoyaltyCardModel, refreshedLinkedState: @escaping (LoyaltyCardPLLState) -> Void ) -> LoyaltyCardPLLState {
        let pllState = wallet.configurePLLState(for: loyaltyCard)
        
        wallet.fetch { [weak self] in
            if let refreshedState = self?.wallet.configurePLLState(for: loyaltyCard) {
                refreshedLinkedState(refreshedState)
            }
        }
        
        return pllState
    }
    
    public func pllStatus(for paymentAccount: PaymentAccountResponseModel, refreshedLinkedState: @escaping (PaymentAccountPLLState) -> Void ) -> PaymentAccountPLLState {
        let pllState = wallet.configurePLLState(for: paymentAccount)
        
        wallet.fetch { [weak self] in
            if let refreshedState = self?.wallet.configurePLLState(for: paymentAccount) {
                refreshedLinkedState(refreshedState)
            }
        }
        
        return pllState
    }
}
