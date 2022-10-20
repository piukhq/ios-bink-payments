//
//  BinkPaymentsManager.swift
//  
//
//  Created by Ricardo Silva on 13/09/2022.
//

import UIKit

public class BinkPaymentsManager: NSObject, UINavigationControllerDelegate {
    public static let shared = BinkPaymentsManager()
    private var token: String!
    private var environmentKey: String!
    
    private var currentViewController: UIViewController? {
        return UIViewController.topMostViewController()
    }

    private override init() {}
    
    public func configure(token: String!, environmentKey: String!) {
        assert(!token.isEmpty && !environmentKey.isEmpty, "Bink Payments SDK Error - Not Initialised due to missing token/environment key")
        
        self.token = token
        self.environmentKey = environmentKey
        print("Bink Payments SDK Initialised")
    }
    
    public func launchScanner(delegate: BinkScannerViewControllerDelegate) {
        let binkScannerViewController = BinkScannerViewController()
        binkScannerViewController.delegate = delegate
        currentViewController?.present(binkScannerViewController, animated: true)
    }
    
    public func launchDebugScreen(paymentCard: PaymentCardCreateModel) {
        let debugScreen = DebugViewController(paymentCard: paymentCard)
        let navigationController = UINavigationController(rootViewController: debugScreen)
        currentViewController?.present(navigationController, animated: true)
    }
    
    public func launchAddPaymentCardScreen(_ paymentCard: PaymentCardCreateModel? = nil) {
        let addPaymentCardViewController = AddPaymentCardViewController(viewModel: AddPaymentCardViewModel(paymentCard: paymentCard))
        let navigationController = UINavigationController(rootViewController: addPaymentCardViewController)
        currentViewController?.show(navigationController, sender: nil)
    }
}

