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
    
    @IBOutlet var addQualificationView: UIView!
    var blurEffectView: UIVisualEffectView?
    
    @IBOutlet weak var qualificationNameTextField: UITextField!
    @IBOutlet weak var numberOfUnitsTextField: UITextField!
    
    var addedQualification: Qualification?
    var addedUnit: Unit?
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBAction func closePopUp(_ sender: UIButton) {
        animateOut()
    }
    
    let realm = try! Realm()
    lazy var qualifications: Results<Qualification> = { self.realm.objects(Qualification.self) }()
    
    var selectedQualification: Qualification!
//    var selectedQualificationIndex: IndexPath?
    
    @IBAction func addQualification(_ sender: AnyObject) {
        animateIn()
    }
    
    @IBAction func saveButton(_ sender: AnyObject) {
        addNewQualification()
        addNewComponents()
        
        animateOut()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // It is important to define a navigationController delegate! In this case
        // I used the ViewController as delegate... but it is not mandatory
        self.navigationController?.delegate = self
        
        addQualificationView.layer.cornerRadius = 5
        
//        navigationController?.navigationBar.barTintColor = UIColor(red: 41.0/255, green: 128.0/255, blue: 185.0/255, alpha: 1.0)
//        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.topItem?.title = "Qualifications"
        
//        if let navController = self.navigationController {
//            navController.navigationBar.tintColor = UIColor.blue
//            navController.navigationBar.barTintColor = UIColor.white
//            navController.navigationBar.isTranslucent = false
//            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black]
//        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadQualifications(_:)),name:NSNotification.Name(rawValue: "load"), object: nil)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if let navController = self.navigationController {
//            navController.navigationBar.tintColor = UIColor.blue
//            navController.navigationBar.barTintColor = UIColor.white
//            navController.navigationBar.isTranslucent = false
//            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black]
//        }
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
    
    func animateIn() {
        blur()
        
        self.view.addSubview(addQualificationView)
        
        addQualificationView.center = CGPoint(x: view.frame.size.width / 2, y: (view.frame.size.height / 2) - 50.0) //self.view.center
        
        addQualificationView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addQualificationView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            // visual effect view here
            
            self.addQualificationView.alpha = 1
            self.addQualificationView.transform = CGAffineTransform.identity
        }
        addButton.isEnabled = false
        editButtonItem.isEnabled = false
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.addQualificationView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.addQualificationView.alpha = 0
            
        }) { (success:Bool) in
            self.addQualificationView.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
        }
        addButton.isEnabled = true
        editButtonItem.isEnabled = true
    }
    
    func blur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView!)
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
                newComponents.weighting = Double((100 / Double(addedQualification!.numberOfComponents)) / 100).rounded()
                
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
        
//        let screenRect = UIScreen.main.bounds
//        let screenWidth = screenRect.size.width
//        let cellW = (screenWidth - 2) / 3
//        let cellH = cellW
//        
//        return CGSize(width: cellW, height: cellH)
        
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
