//
//  AddQualificationViewController.swift
//  MyGCSEGradeTracker
//
//  Created by George Davies on 01/12/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit

class AddQualificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonBtmConstraint: NSLayoutConstraint!
    
    var textViewOutput = ["", ""]
    
    var componentPercentages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    @IBAction func saveQualification(_ sender: Any) {
        print(textViewOutput)
        print(componentPercentages)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            self.buttonBtmConstraint.constant = keyboardHeight;
        }
        self.view.layoutIfNeeded();
        print(keyboardHeight);
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
            return "Qualification Details"
        } else {
            return "Components"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: CustomTableViewCell?
        
        if indexPath.section == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomTableViewCell?
            
            switch indexPath.row {
            case 0:
                cell?.labelOutlet.text = "Qualification Name"
                cell?.placeholderTextOutlet.placeholder = "e.g. Maths"
            case 1:
                cell?.labelOutlet.text = "No. of Components"
                cell?.placeholderTextOutlet.placeholder = "e.g. 4"
                cell?.placeholderTextOutlet.keyboardType = UIKeyboardType.decimalPad
            default:
                break
            }
            cell?.selectionStyle = .none
            
            cell?.placeholderTextOutlet.tag = indexPath.row
            cell?.placeholderTextOutlet.addTarget(self, action: #selector(textViewValueChange), for: .editingChanged)
        }
        
        if indexPath.section == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! CustomTableViewCell?
            cell?.labelOutlet.text = "Edit Components"
            cell?.accessoryType = .disclosureIndicator
        }
        
        return cell!
    }
    
    func textViewValueChange(sender: UITextField) {
        
        let currentValue = sender.text
        let textRow = sender.tag
        
        textViewOutput.remove(at: textRow)
        textViewOutput.insert(currentValue!, at: textRow)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! CustomTableViewCell?
        cell?.contentView.backgroundColor = .orange
        
        switch (indexPath.section, indexPath.row) {
        case (1, _):
            print("Cell 3 tapped")
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! CustomTableViewCell?
            cell?.contentView.backgroundColor = .white
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowComponents" {
            let destinationVC = segue.destination as? ComponentTableViewController
            destinationVC?.numberOfComponents = Int(textViewOutput[1])
        }
    }
}
