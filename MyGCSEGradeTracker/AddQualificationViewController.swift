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
    var textViewOutput = ["",""]
    
    var componentWeightings = [String]()
    var componentTitleArray = [String]()
    var componentsIndexPath = [IndexPath]()
    
    var addedQualification: Qualification?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func cancelAddQualification(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveQualification(_ sender: Any) {
        if validateWeightings() && validateQualificationName() {
            
            addNewQualification()
            addNewComponents()
            Flurry.logEvent("Added-Qualification")
            dismiss(animated: true, completion: nil)
            
        } else if textViewOutput[0] == "" {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Qualification Name Missing", comment: ""))", message: "\(NSLocalizedString("Please enter a name for the qualification", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
            self.present(alert, animated: true, completion: nil)
            
        } else if textViewOutput[1] == "" {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Components Missing", comment: ""))", message: "\(NSLocalizedString("Please input the number of components", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
            self.present(alert, animated: true, completion: nil)
            
        } else if validateWeightings() == false && validateQualificationName() {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Incorrect Weightings", comment: ""))", message: "\(NSLocalizedString("Combined component weightings should equal 100%", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
            self.present(alert, animated: true, completion: nil)

        } else {
            
            let alert = UIAlertController(title: "\(NSLocalizedString("Missing Information", comment: ""))", message: "\(NSLocalizedString("Please enter the required information", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
            alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func validateWeightings() -> Bool {
        var sum = 0
        for component in componentWeightings {
            if component != "" {
                sum += Int(component)!
            }
        }
        if sum == 100 {
            return true
        } else {
            return false
        }
    }
    
    func validateQualificationName() -> Bool {
        
        if textViewOutput[0] != "" && textViewOutput[1] != "" {
            return true
        }else{
            return false
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
            return "\(NSLocalizedString("Components", comment: ""))" 
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
                cell?.placeholderTextOutlet.placeholder = "\(NSLocalizedString("e.g. Maths", comment: ""))"
                cell?.placeholderTextOutlet.autocapitalizationType = .words
            case 1:
                cell?.labelOutlet.text = "\(NSLocalizedString("No. of Components", comment: ""))" 
                cell?.placeholderTextOutlet.placeholder = "\(NSLocalizedString("e.g.", comment: "")) 4" 
                cell?.placeholderTextOutlet.keyboardType = UIKeyboardType.numberPad
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
            cell?.accessoryType = .disclosureIndicator
            
            
        } else if indexPath.section == 1 && indexPath.row != 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell?
            cell?.placeholderTextOutlet.tag = indexPath.row + 1
            cell?.selectionStyle = .none
            cell?.placeholderTextOutlet.addTarget(self, action: #selector(textViewValueChange), for: .editingChanged)
            cell?.placeholderTextOutlet.keyboardType = UIKeyboardType.decimalPad
            
            if componentTitleArray.isEmpty {
                cell?.labelOutlet.text = ""
                cell?.placeholderTextOutlet.placeholder = ""
            }else{
                cell?.labelOutlet.text = componentTitleArray[indexPath.row - 1]
                cell?.placeholderTextOutlet.placeholder = "\(NSLocalizedString("e.g.", comment: "")) \(100 / componentTitleArray.count)%" 
            }
        }
        
        return cell!
    }
    
    func textViewValueChange(sender: UITextField) {
        
        let currentValue = sender.text
        let textRow = sender.tag
        
        if textRow < 2 {
            textViewOutput.remove(at: textRow)
            textViewOutput.insert(currentValue!, at: textRow)
        } else {
            componentWeightings.remove(at: textRow - 2)
            componentWeightings.insert(currentValue!, at: textRow - 2)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            
            if textViewOutput[1] == "" {
                
                let alert = UIAlertController(title: "\(NSLocalizedString("Missing Information", comment: ""))", message: "\(NSLocalizedString("Please input the number of components", comment: ""))", preferredStyle: UIAlertControllerStyle.alert) 
                alert.addAction(UIAlertAction(title: "\(NSLocalizedString("OK", comment: ""))", style: UIAlertActionStyle.default, handler: nil)) 
                self.present(alert, animated: true, completion: nil)
                
            }else {
                DispatchQueue.main.async {
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
                
                if componentsIndexPath.isEmpty {
                    updateComponentRows()
                } else if tableView.numberOfRows(inSection: 1) == Int(textViewOutput[1])! + 1 {
                } else {
                    
                    for i in 1...componentTitleArray.count {
                        if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1)) as? CustomTableViewCell {
                            cell.placeholderTextOutlet.text = ""
                        }
                    }
                    numRowsSection1 = 1
                    tableView.deleteRows(at: componentsIndexPath, with: .automatic)
                    componentsIndexPath.removeAll()
                    componentTitleArray.removeAll()
                    componentWeightings.removeAll()
                    
                    updateComponentRows()
                }
            }
            
        default:
            break
        }

    }
    
    func updateComponentRows() {
        for i in 0..<Int(textViewOutput[1])! {
            componentsIndexPath.append(IndexPath(row: i + 1, section: 1))
            componentTitleArray.append("\(NSLocalizedString("Component", comment: "")) \(i + 1)") 
            componentWeightings.append("")
            
        }
        
        numRowsSection1 = Int(textViewOutput[1])! + 1
        
        tableView.beginUpdates()
        tableView.insertRows(at: componentsIndexPath, with: .automatic)
        tableView.endUpdates()
    }
    
    func addNewQualification() {
        let realm = try! Realm()
        
        try! realm.write {
            let newQualification = Qualification()
            
            newQualification.name = textViewOutput[0]
            newQualification.numberOfComponents = Int(textViewOutput[1])!
            
            realm.add(newQualification)
            self.addedQualification = newQualification
        }
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "load"), object: nil)
    }
    
    func addNewComponents() {
        let realm = try! Realm()
        
        let parameters = ["Number-of-Components" : Int(textViewOutput[1])!]
        Flurry.logEvent("Added-Components", withParameters: parameters)
        
        var i = 1
        while i <= Int(textViewOutput[1])! {
            
            try! realm.write {
                
                let newComponents = Component()
                
                newComponents.name = "\(NSLocalizedString("Component", comment: "")) \(i)" 
                newComponents.qualification = textViewOutput[0]
                newComponents.weighting = (Double(componentWeightings[i - 1])! / 100)
                i += 1
                realm.add(newComponents)
            }            
        }
    }
}
