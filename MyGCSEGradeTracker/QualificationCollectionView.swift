//
//  QualificationCollectionViewCell.swift
//  My Grade Tracker
//
//  Created by George Davies on 19/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift
import Flurry_iOS_SDK

class QualificationCollectionView: UICollectionViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var sourceCell: UICollectionViewCell?
    
    let imageView = UIImageView(image: UIImage(named: "AddQualificationImage1")!)
    
    let userDefaultsKey = "HasUpgradedUserDefaultsKey"
    var hasUpgradedBool: Bool?
    var product_id = "com.GDaviesDev.MyGCSEGradeTracker.upgrade"
    
    let colorsArray = [
        UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0),
        UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0),
        UIColor(red: 155/255.0, green: 89/255.0, blue: 182/255.0, alpha: 1.0),
        UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0),
        UIColor(red: 230/255.0, green: 126/255.0, blue: 34/255.0, alpha: 1.0),
        UIColor(red: 231/255.0, green: 76/255.0, blue: 60/255.0, alpha: 1.0),
        UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1.0),
        ]
    
    var addedQualification: Qualification?
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let realm = try! Realm()
    lazy var qualifications: Results<Qualification> = { self.realm.objects(Qualification.self) }()
    
    var selectedQualification: Qualification!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
        navigationController?.navigationBar.topItem?.title = "Qualifications"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadQualifications(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            portraitLayoutCells()
        } else {
            landscapeLayoutCells()
        }
        print("File location: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
        hasUpgradedBool = UserDefaults.standard.bool(forKey: userDefaultsKey)
        navigationController?.setToolbarHidden(false, animated: true)
        if qualifications.count == 0 {
            layoutImageView()
        }else{
            if imageView.superview === self.view {
                imageView.removeFromSuperview()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orientation = UIApplication.shared.statusBarOrientation
            switch orientation {
            case .portrait:
                self.portraitLayoutCells()
            default:
                self.landscapeLayoutCells()
            }
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            print("rotation completed")
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return qualifications.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomQualificationCollectionViewCell
        
        let qualification = qualifications[(indexPath as NSIndexPath).row]
        
        cell.qualificationLabel.text = qualification.name
        cell.numberOfComponentsLabel.text = "Components: \(String(qualification.numberOfComponents))"
        cell.backgroundColor = colorsArray[indexPath.row % colorsArray.count]
        return cell
    }
    
    // MARK: Cells layouts
    func portraitLayoutCells() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: (width / 2) - 5, height: (width / 2) - 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        self.collectionView!.collectionViewLayout = layout
    }

    func landscapeLayoutCells() {
        let horizontalLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        horizontalLayout.itemSize = CGSize(width: (width / 3) - 5, height: (width / 3) - 5)
        horizontalLayout.minimumInteritemSpacing = 5
        horizontalLayout.minimumLineSpacing = 10
        self.collectionView!.collectionViewLayout = horizontalLayout
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowQualification" {
            
            let vc = segue.destination as! QualificationsViewController
            let cell = sender as! CustomQualificationCollectionViewCell
            let indexPath = collectionView?.indexPath(for: cell)

            sourceCell = cell
            vc.selectedQualification = qualifications[(indexPath?.row)!]
            vc.sourceCell = cell
            vc.targetPercentage = defaults.object(forKey: "TargetPercentage") as? Double
        } else if segue.identifier == "ManageQualifications" {
            Flurry.logEvent("Managed-Qualifications")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "AddQual" {
            if qualifications.count == 4 && !hasUpgraded() {
                
                let alertController = UIAlertController(title: "Upgrade for More Qualifications", message: "Upgrade for 79p to allow more than four qualifications.", preferredStyle: .actionSheet)
                
                alertController.addAction(UIAlertAction(title: "Upgrade", style: .default, handler: { (action) in
                    //execute some code when this option is selected
                    self.upgrade()
                }))
                alertController.addAction(UIAlertAction(title: "Restore Purchase", style: .default, handler: { (action) in
                    //execute some code when this option is selected
                    SKPaymentQueue.default().restoreCompletedTransactions()
                }))
                
                alertController.addAction(UIAlertAction(title: "Later", style: .cancel, handler: { (action) in
                }))
                
                self.present(alertController, animated: true) {
                }
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    func loadQualifications(_ notification: Foundation.Notification){
        //load data here
        self.collectionView?.reloadData()
    }

    @IBAction func addTargetButton(_ sender: Any) {
        let target = defaults.object(forKey: "TargetPercentage") as? Double
        var message: String?
        if let tgt = target {
            message = "Your target is currently \(Int(tgt)). Please input your new target:"
        } else {
            message = "Please input your target:"
        }
        let alertController = UIAlertController(title: "Target Percentage", message: message!, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                // store data
                self.defaults.set(Double(field.text!), forKey: "TargetPercentage")
                self.defaults.synchronize()
            } else {
                // user did not enter anything
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField: UITextField!) in
            textField.keyboardType = UIKeyboardType.numberPad
            textField.placeholder = "Target %"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Upgrade or restore purchase
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Got the request")
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
            print("No products")
        }
    }
    
    func buyProduct(_ product: SKProduct){
        print("Sending the payment request")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received payment transaction response")
        
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
                    let alertController = UIAlertController(title: "Purchase Failed", message: "Your purchase failed, please try again.", preferredStyle: .alert)
                    alertController.addAction(doneAction)
                    self.present(alertController, animated: true, completion: nil)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func hasUpgraded() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    func upgrade(){
        print("Going to fetch product")
        // Check if it's possible to make the purchase
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
    
    //MARK: Auto Layout Constraints For ImageView
    
    func addImageViewConstraints() {
        let navBarHeight = Int(navigationController!.navigationBar.frame.height) + 20
        let width = UIScreen.main.bounds.width

        let imageViewTrailingConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal
            , toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        
        let imageViewTopConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal
            , toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: CGFloat(navBarHeight))
        
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (width / 2) - 5))
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (width / 2) - 5))
        
        NSLayoutConstraint.activate([imageViewTrailingConstraint, imageViewTopConstraint])
    }
    
    func layoutImageView() {
        let screenSize = UIScreen.main.bounds
        let navBarHeight = Int(navigationController!.navigationBar.frame.height) + 20
        imageView.frame = CGRect(x: Int(screenSize.width - 100), y: navBarHeight, width: 100, height: 100)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addImageViewConstraints()
    }
}















