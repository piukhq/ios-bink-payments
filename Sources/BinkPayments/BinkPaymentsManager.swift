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
    var wallet = Wallet()
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
//        NetworkActivityLogger.shared.startLogging()
        if !isDebug {
            print("Warning: You are running a DEBUG session but not in Test Mode!")
        }
        #endif
        
        wallet.fetch()
    }
    
    public func launchScanner(delegate: BinkScannerViewControllerDelegate) {
        let binkScannerViewController = BinkScannerViewController()
        binkScannerViewController.delegate = delegate
        currentViewController?.present(binkScannerViewController, animated: true)
    }
    
    public func launchDebugScreen(paymentCard: PaymentAccountCreateModel) {
        let debugScreen = DebugViewController(paymentCard: paymentCard)
        currentViewController?.present(debugScreen, animated: true)
    }
    
    public func launchAddPaymentCardScreen(_ paymentCard: PaymentAccountCreateModel? = nil) {
        let addPaymentCardViewController = AddPaymentCardViewController(viewModel: AddPaymentCardViewModel(paymentCard: paymentCard))
        let navigationController = UINavigationController(rootViewController: addPaymentCardViewController)
        currentViewController?.show(navigationController, sender: nil)
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

public struct LoyaltyCardPLLState {
    var linked: [PaymentAccountResponseModel]
    var unlinked: [PaymentAccountResponseModel]
    var timeChecked: Date?
}


public struct PaymentAccountPLLState {
    var linked: [LoyaltyCardModel]
    var unlinked: [LoyaltyCardModel]
    var timeChecked: Date?
}
