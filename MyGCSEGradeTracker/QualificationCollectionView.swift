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

class QualificationCollectionView: UICollectionViewController {
    
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
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    let realm = try! Realm()
    lazy var qualifications: Results<Qualification> = { self.realm.objects(Qualification.self) }()
    
    var selectedQualification: Qualification!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Qualifications"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadQualifications(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        print("File location: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
        hasUpgraded = UserDefaults.standard.bool(forKey: userDefaultsKey)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

            sourceCell = cell
            vc.selectedQualification = qualifications[(indexPath?.row)!]
            vc.sourceCell = cell
        } else if segue.identifier == "ManageQualifications" {
            Flurry.logEvent("Managed-Qualifications")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "AddQual" {
            if qualifications.count == 4 && hasUpgraded == false {
                
                let alertController = UIAlertController(title: "Please Upgrade", message: "In order to add more than one qualification please upgrade.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Later", style: .cancel) { action in
                }
                alertController.addAction(cancelAction)
                
                let upgradeAction = UIAlertAction(title: "Upgrade", style: .default) { action in
                    self.performSegue(withIdentifier: "ShowUpgradeViewController", sender: nil)
                }
                alertController.addAction(upgradeAction)
                
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
//
////MARK: UINavigationControllerDelegate
//extension QualificationCollectionView: UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        // In this method belonging to the protocol UINavigationControllerDelegate you must
//        // return an animator conforming to the protocol UIViewControllerAnimatedTransitioning.
//        // To perform the Pop in and Out animation PopInAndOutAnimator should be returned
//        return PopInAndOutAnimator(operation: operation)
//    }
//}
//
////MARK: CollectionPushAndPoppable
//extension QualificationCollectionView: CollectionPushAndPoppable {}
