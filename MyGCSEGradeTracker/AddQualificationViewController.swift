//
//  AddQualificationViewController.swift
//  MyGCSEGradeTracker
//
//  Created by George Davies on 01/12/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift
import Flurry_iOS_SDK

class AddQualificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonBtmConstraint: NSLayoutConstraint!
    
    var numRowsSection1 = 1
    var textViewOutput: [Int:String] = [:]
    
    var componentWeightings: [Int:Int] = [:]
    var componentTitleArray = [String]()
    var componentsIndexPath = [IndexPath]()
    
    var addedQualification: Qualification?
    
    let realm = try! Realm()
    lazy var qualifications: Results<Qualification> = { self.realm.objects(Qualification.self) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func cancelAddQualification(sender: AnyObject) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveQualification(_ sender: Any) {
        if textViewOutput[0] == nil || textViewOutput[0] == "" {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Qualification Name Missing", comment: ""))", message: "\(NSLocalizedString("Please enter a name for the qualification", comment: ""))", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
            self.present(alert, animated: true, completion: nil)
            
        } else if !validateQualName() {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Invalid Qualification Name", comment: ""))", message: "\(NSLocalizedString("A qualification with this name already exists, please change it and try again", comment: ""))", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil) //***
            
        } else if textViewOutput[1] == nil || textViewOutput[1] == "" {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Components Missing", comment: ""))", message: "\(NSLocalizedString("Please input the number of components", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
            self.present(alert, animated: true, completion: nil)
            
        } else if Int(textViewOutput[1]!)! > 12 {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Over Component Limit", comment: ""))", message: "\(NSLocalizedString("There is a limit of 12 Components per qualification, please enter fewer than 12", comment: ""))", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil) //***

            
        } else if !validateWeightings() {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Incorrect Weightings", comment: ""))", message: "\(NSLocalizedString("Combined component weightings should equal 100%", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
            self.present(alert, animated: true, completion: nil)
            
        }else if !validateNumberOfRows() {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Component Mismatch", comment: ""))", message: "\(NSLocalizedString("The number of components does not match the weightings. Please check this", comment: ""))", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil) //***
            
        } else  if validateWeightings() && validateQualName() { // Correct weightings and qual name and number of sets entered
            view.endEditing(true)
            addNewQualification()
            addNewComponents()
            Flurry.logEvent("Added-Qualification")
            dismiss(animated: true, completion: nil)
        } else {
        //*** Possibly redundant ***//
            let alert = UIAlertController(title: "\(NSLocalizedString("Missing Information", comment: ""))", message: "\(NSLocalizedString("Please enter the required information", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            self.buttonBtmConstraint.constant = keyboardHeight;
        }
        self.view.layoutIfNeeded();
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.buttonBtmConstraint.constant = 0;
        }
        self.view.layoutIfNeeded();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "\(NSLocalizedString("Qualification Details", comment: ""))" 
        } else {
            return "\(NSLocalizedString("Component Weightings", comment: ""))" 
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return numRowsSection1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: CustomTableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell?
            
            switch indexPath.row {
            case 0:
                cell?.labelOutlet.text = "\(NSLocalizedString("Qualification Name", comment: ""))" 
                cell?.placeholderTextOutlet.autocapitalizationType = .words
                if textViewOutput[0] != nil {
                    cell?.placeholderTextOutlet.text = textViewOutput[0]
                } else {
                    cell?.placeholderTextOutlet.placeholder = "\(NSLocalizedString("e.g. Maths", comment: ""))"
                }
            case 1:
                cell?.labelOutlet.text = "\(NSLocalizedString("No. of Components", comment: ""))" 
                cell?.placeholderTextOutlet.keyboardType = UIKeyboardType.numberPad
                if textViewOutput[1] != nil {
                    cell?.placeholderTextOutlet.text = textViewOutput[1]
                } else {
                    cell?.placeholderTextOutlet.placeholder = "\(NSLocalizedString("e.g.", comment: "")) 4"
                }
            default:
                break
            }
            cell?.selectionStyle = .none
            cell?.placeholderTextOutlet.tag = indexPath.row
            cell?.placeholderTextOutlet.addTarget(self, action: #selector(textViewValueChange), for: .editingChanged)
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! CustomTableViewCell?
            cell?.labelOutlet.text = "\(NSLocalizedString("Edit Components", comment: ""))"
            cell?.labelOutlet.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
            cell?.accessoryType = .disclosureIndicator
            
            
        } else if indexPath.section == 1 && indexPath.row != 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell3") as! CustomTableViewCell?
            cell?.placeholderTextOutlet.tag = indexPath.row + 1
            cell?.selectionStyle = .none
            cell?.placeholderTextOutlet.addTarget(self, action: #selector(textViewValueChange), for: .editingChanged)
            cell?.placeholderTextOutlet.keyboardType = UIKeyboardType.numberPad
            
            if componentTitleArray.isEmpty {
//                cell?.labelOutlet.text = ""
//                cell?.placeholderTextOutlet.placeholder = ""
            }else{
                cell?.labelOutlet.text = "Component \(indexPath.row)"
                if let numOfComponents = textViewOutput[1] {
                    cell?.placeholderTextOutlet.placeholder = "\(NSLocalizedString("e.g.", comment: "")) \(100 / Int(numOfComponents)!)%"
                }
            }
        }
        
        return cell!
    }
    
    func textViewValueChange(sender: UITextField) {
        let currentValue = sender.text
        let textRow = sender.tag
        
        if textRow < 2 {
            textViewOutput.removeValue(forKey: textRow)
            if currentValue != nil && currentValue != "" {
                textViewOutput.updateValue(currentValue!, forKey: textRow)
            }
        } else {
            componentWeightings.removeValue(forKey: textRow - 2)
            if currentValue != nil && currentValue != "" {
                    componentWeightings.updateValue(Int(currentValue!)!, forKey: textRow - 2)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            
            if textViewOutput[1] == nil {
                
                let alert = UIAlertController(title: "\(NSLocalizedString("Missing Information", comment: ""))", message: "\(NSLocalizedString("Please input the number of components", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
                alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
                self.present(alert, animated: true, completion: nil)
                
            }else{
                DispatchQueue.main.async {
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
                if componentsIndexPath.isEmpty {
                    updateComponentRows()
                } else if validateNumberOfRows() {
                    // Do nothing when 'Edit Components' pressed but number of components hasn't changed
                } else {
                    for i in 1...componentTitleArray.count {
                        if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1)) as? CustomTableViewCell {
                            cell.placeholderTextOutlet.text = ""
                        }
                    }
                }
                updateAndShowNumberOfComponentCells()
            }
        default:
            break
        }
    }
    
    // MARK: Form input validation
    func validateWeightings() -> Bool {
        var sum = 0
        var i = 0
        if let numOfComponents = textViewOutput[1] {
            while i < Int(numOfComponents)! {
                if componentWeightings[i] != nil && componentWeightings[i] != 0 {
                    sum += Int(componentWeightings[i]!)
                    i += 1
                }else{
                    i += 1
                }
            }
        }
        if sum == 100 {
            return true
        } else {
            return false
        }
    }

    func validateNumberOfRows() -> Bool {
        if let textViewOne = textViewOutput[1] {
            if tableView.numberOfRows(inSection: 1) == Int(textViewOne)! + 1 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func validateQualName() -> Bool {
        for qual in qualifications {
            if let qualName = textViewOutput[0] {
                if qual.name == qualName {
                    return false
                }
            }
        }
        return true
    }
    
    func updateComponentRows() {
        if let numOfComponents = textViewOutput[1] {
            for i in 0..<Int(numOfComponents)! {
                componentsIndexPath.append(IndexPath(row: i + 1, section: 1))
                componentTitleArray.append("\(NSLocalizedString("Component", comment: "")) \(i + 1)")
            }
            numRowsSection1 = Int(numOfComponents)! + 1
        }
        tableView.beginUpdates()
        tableView.insertRows(at: componentsIndexPath, with: .automatic)
        tableView.endUpdates()
    }
    
    func addNewQualification() {
        let realm = try! Realm()
        
        try! realm.write {
            let newQualification = Qualification()
            if textViewOutput[0] != nil && textViewOutput[1] != nil {
            newQualification.name = textViewOutput[0]!
            newQualification.numberOfComponents = Int(textViewOutput[1]!)!
            }
            
            realm.add(newQualification)
            self.addedQualification = newQualification
        }
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "load"), object: nil)
    }
    
    func addNewComponents() {
        let realm = try! Realm()
        let parameters = ["Number-of-Components" : Int(textViewOutput[1]!)!]
        Flurry.logEvent("Added-Components", withParameters: parameters)
        
        var i = 1
        while i <= Int(textViewOutput[1]!)! {
            
            try! realm.write {
                let newComponents = Component()
                
                newComponents.name = "\(NSLocalizedString("Component", comment: "")) \(i)" 
                newComponents.qualification = textViewOutput[0]!
                newComponents.weighting = (Double(componentWeightings[i - 1]!) / 100)
                i += 1
                realm.add(newComponents)
            }            
        }
    }
    
    func updateAndShowNumberOfComponentCells() {
        numRowsSection1 = 1
        tableView.deleteRows(at: componentsIndexPath, with: .automatic)
        componentsIndexPath.removeAll()
        componentTitleArray.removeAll()
        componentWeightings.removeAll()
        updateComponentRows()
    }
}
