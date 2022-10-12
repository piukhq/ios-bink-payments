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
        let currentViewController = UIViewController.topMostViewController()
        currentViewController?.present(binkScannerViewController, animated: true)
    }
}

extension UIViewController {
    static public func topMostViewController() -> UIViewController? {
        let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
        if var topController = window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

