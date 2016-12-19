//
//  UpgradeManager.swift
//  IAPDemo
//
//  Created by Hesham Abd-Elmegid on 8/18/16.
//  Copyright © 2016 CareerFoundry. All rights reserved.
//

import Foundation
import StoreKit

class UpgradeManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let sharedInstance = UpgradeManager()
    let productIdentifier = "com.GDaviesDev.MyGCSEGradeTracker.upgrade"
    typealias SuccessHandler = (_ succeeded: Bool) -> (Void)
    var upgradeCompletionHandler: SuccessHandler?
    var restoreCompletionHandler: SuccessHandler?
    var priceCompletionHandler: ((_ price: Float) -> Void)?
    var famousQuotesProduct: SKProduct?
    let userDefaultsKey = "HasUpgradedUserDefaultsKey"
    
    func hasUpgraded() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    func upgrade(_ success: @escaping SuccessHandler) {
        upgradeCompletionHandler = success
        
        if let product = famousQuotesProduct {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases(_ success: @escaping SuccessHandler) {
        restoreCompletionHandler = success
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func priceForUpgrade(_ success: @escaping (_ price: Float) -> Void) {
        priceCompletionHandler = success
        
        let identifiers: Set<String> = [productIdentifier]
        let request = SKProductsRequest(productIdentifiers: identifiers)
        request.delegate = self
        request.start()
    }
    
    // MARK: SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                UserDefaults.standard.set(true, forKey: userDefaultsKey)
                upgradeCompletionHandler?(true)
            case .restored:
                UserDefaults.standard.set(true, forKey: userDefaultsKey)
                restoreCompletionHandler?(true)
            case .failed:
                upgradeCompletionHandler?(false)
            default:
                return
            }
            
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    // MARK: SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        famousQuotesProduct = response.products.first
        
        if let price = famousQuotesProduct?.price {
            priceCompletionHandler?(Float(price))
        }
    }
}
