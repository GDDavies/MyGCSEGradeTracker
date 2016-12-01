//
//  QualificationCollectionViewCell.swift
//  My Grade Tracker
//
//  Created by George Davies on 19/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift

class QualificationCollectionView: UICollectionViewController {
    
    var sourceCell: UICollectionViewCell?
    
    var screenWidth: CGFloat!
    var screenSize: CGRect!
    
    let colorsArray = [
        UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0),
        UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0),
        UIColor(red: 155/255.0, green: 89/255.0, blue: 182/255.0, alpha: 1.0),
        UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0),
        UIColor(red: 230/255.0, green: 126/255.0, blue: 34/255.0, alpha: 1.0),
        UIColor(red: 231/255.0, green: 76/255.0, blue: 60/255.0, alpha: 1.0),
        UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1.0),
        ]
    
    @IBOutlet weak var qualificationNameTextField: UITextField!
    @IBOutlet weak var numberOfUnitsTextField: UITextField!
    
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
    
    @IBAction func saveButton(_ sender: AnyObject) {
        addNewQualification()
        addNewComponents()

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
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        cell.numberOfUnitsLabel.text = "Units: \(String(qualification.numberOfComponents))"
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
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectedQualificationIndex = indexPath
//    }
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print(indexPath)
//    }
    
    func loadQualifications(_ notification: Foundation.Notification){
        //load data here
        self.collectionView?.reloadData()
    }
    
    func addNewQualification() {
        let realm = try! Realm()
        
        try! realm.write {
            let newQualification = Qualification()
            
            newQualification.name = qualificationNameTextField.text!
            newQualification.numberOfComponents = Int(numberOfUnitsTextField.text!)!
            
            realm.add(newQualification)
            self.addedQualification = newQualification
        }
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "load"), object: nil)
    }
    
    func addNewComponents() {
        let realm = try! Realm()
        
        var i = 1
        while i <= (addedQualification?.numberOfComponents)! {
            
            try! realm.write {
                
                let newComponents = Component()
                
                newComponents.name = "Component \(i)"
                newComponents.qualification = qualificationNameTextField.text!
                
                // Default weighting - NEEDS CHANGING TO ALLOW INPUT
                newComponents.weighting = Double((100 / Double(addedQualification!.numberOfComponents)) / 100).roundTo(places: 3)
                
                i += 1
                realm.add(newComponents)
            }
            
            //            self.addedUnit = newUnits
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowQualification" {
//            if let destinationVC = segue.destination as? QualResultViewController {
//                destinationVC.selectedQual = selectedQualification.name
//            }
//        }
//    }

    
///////////////////////////////////////////////////////////////////////////////
    
//    func deleteRowAtIndexPath(_ indexPath: IndexPath) {
//        let realm = try! Realm()
//        try! realm.write {
//            realm.delete(qualifications[(indexPath as NSIndexPath).row])
//        }
//        tableView.deleteRows(at: [indexPath], with: .fade)
//    }
//    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if isEditing == true {
//            deleteRowAtIndexPath(indexPath)
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath {
//        selectedQualification = qualifications[(indexPath as NSIndexPath).row]
//        return indexPath
//    }
//    

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

//MARK: CollectionPushAndPoppable
extension QualificationCollectionView: CollectionPushAndPoppable {}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
