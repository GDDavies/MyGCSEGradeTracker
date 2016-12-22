//
//  QualificationCollectionViewCell.swift
//  My Grade Tracker
//
//  Created by George Davies on 19/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift

class QualificationCollectionView: UICollectionViewController, CollectionPushAndPoppable {
    
    var sourceCell: UICollectionViewCell?
    
    var screenWidth: CGFloat!
    var screenSize: CGRect!
    
    let userDefaultsKey = "HasUpgradedUserDefaultsKey"
    var hasUpgraded: Bool?
        
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
    var addedUnit: Unit?
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let realm = try! Realm()
    lazy var qualifications: Results<Qualification> = { self.realm.objects(Qualification.self) }()
    
    var selectedQualification: Qualification!
//    var selectedQualificationIndex: IndexPath?
    
    @IBAction func addQualification(_ sender: AnyObject) {
        //animateIn()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
        
        navigationController?.navigationBar.topItem?.title = "Qualifications"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadQualifications(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        
        print("File location: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        UIView.animate(withDuration: 1, delay: 0.0, options:[.curveLinear], animations: {
//            self.navigationController?.navigationBar.barTintColor = UIColor.white
//        }, completion:nil)
        collectionView?.reloadData()
        
        hasUpgraded = UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        //cell.detailTextLabel?.text = "\(String(qualification.numberOfComponents)) Components"
        
        cell.qualificationLabel.text = qualification.name
        cell.numberOfComponentsLabel.text = "Components: \(String(qualification.numberOfComponents))"
        cell.backgroundColor = colorsArray[indexPath.row % colorsArray.count]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowQualification" {
            
            let vc = segue.destination as! QualificationsViewController
            let cell = sender as! CustomQualificationCollectionViewCell
            let indexPath = collectionView?.indexPath(for: cell)
            
            // This next line is very importat for the proper functioning of the animation:
            // the sourceCell property tells the animator which is the cell involved in the transition
            sourceCell = cell
            vc.selectedQualification = qualifications[(indexPath?.row)!]
            vc.sourceCell = cell
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "AddQual" {
            if qualifications.count == 4 && hasUpgraded == false {
                
                let alertController = UIAlertController(title: "Please Upgrade", message: "In order to add more than one qualification please upgrade.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Later", style: .cancel) { action in
                    // ...
                }
                alertController.addAction(cancelAction)
                
                let upgradeAction = UIAlertAction(title: "Upgrade", style: .default) { action in
                    self.performSegue(withIdentifier: "ShowUpgradeViewController", sender: nil)
                }
                
                alertController.addAction(upgradeAction)
                
                self.present(alertController, animated: true) {
                    // ...
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowQualification" {
//            if let destinationVC = segue.destination as? QualResultViewController {
//                destinationVC.selectedQual = selectedQualification.name
//            }
//        }
//    }

}

//MARK: UICollectionViewDelegateFlowLayout
extension QualificationCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        
        return CGSize(width: (screenWidth/2) - 5, height: (screenWidth/2) - 5)
    }
}

//MARK: UINavigationControllerDelegate
extension QualificationCollectionView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // In this method belonging to the protocol UINavigationControllerDelegate you must
        // return an animator conforming to the protocol UIViewControllerAnimatedTransitioning.
        // To perform the Pop in and Out animation PopInAndOutAnimator should be returned
        return PopInAndOutAnimator(operation: operation)
    }
}

////MARK: CollectionPushAndPoppable
//extension QualificationCollectionView: CollectionPushAndPoppable {}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
