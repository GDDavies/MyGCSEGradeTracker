//
//  UpgradeViewController.swift
//  IAPDemo
//
//  Created by Hesham Abd-Elmegid on 8/18/16.
//  Copyright © 2016 CareerFoundry. All rights reserved.
//

import UIKit
import StoreKit

class UpgradeViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    var product_id = "com.GDaviesDev.MyGCSEGradeTracker.upgrade"
    let userDefaultsKey = "HasUpgradedUserDefaultsKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
                
//        UpgradeManager.sharedInstance.priceForUpgrade { (price) in
//            self.priceLabel.text = "£\(price)"
//            self.upgradeButton.isEnabled = true
//            self.restoreButton.isEnabled = true
//        }
    }

    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeButtonTapped(_ sender: AnyObject) {
        upgrade()
    }
    
    @IBAction func restorePurchasesButtonTapped(_ sender: AnyObject) {
        print("Restore button tapped")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func hasUpgraded() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    
    func upgrade(){
        print("About to fetch the product");
        // We check that we are allow to make the purchase.
        if (SKPaymentQueue.canMakePayments())
        {
            let identifiers: Set<String> = [product_id]
            let request = SKProductsRequest(productIdentifiers: identifiers)
            request.delegate = self
            request.start()
            print("Fetching product")
        }else{
            print("Can't make purchase")
        }
    }
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Got the request from Apple")
        
        let count = response.products.count
        if (count > 0) {
            let validProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.product_id) {
                print(validProduct.price)
                buyProduct(validProduct);
            } else {
                print(validProduct.productIdentifier)
            }
        } else {
            print("No products. Check ID.")
        }
    }
    
    func buyProduct(_ product: SKProduct){
        print("Sending the Payment Request to Apple")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple")
        
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        })
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    UserDefaults.standard.set(true, forKey: userDefaultsKey)
                    print("Product Purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    let alertController = UIAlertController(title: "Upgraded!", message: "Thanks for upgrading. You can now add more qualifications.", preferredStyle: .alert)
                    alertController.addAction(doneAction)
                    self.present(alertController, animated: true, completion: nil)
                    break
                case .restored:
                    UserDefaults.standard.set(true, forKey: userDefaultsKey)
                    print("Product Restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    let alertController = UIAlertController(title: "Restored!", message: "Your purchases have been restored. You can now add more qualifications.", preferredStyle: .alert)
                    alertController.addAction(doneAction)
                    self.present(alertController, animated: true, completion: nil)
                    break
                case .failed:
                    print("Purchased Failed")
                    //print(transaction.error as Any)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    let alertController = UIAlertController(title: "Purchase Failed", message: "Your purchases failed, please try again.", preferredStyle: .alert)
                    alertController.addAction(doneAction)
                    self.present(alertController, animated: true, completion: nil)
                    break
                default:
                    break
                }
            }
        }
        
    }
}
