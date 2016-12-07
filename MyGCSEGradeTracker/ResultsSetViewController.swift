//
//  ResultsSetViewController.swift
//  My Grade Tracker
//
//  Created by George Davies on 19/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift

class ResultsSetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var resultType: UISegmentedControl!
    var selectedQual: String?
    var selectedQualification: Qualification!
    var selectedComponent: Component!
    
    var selectedGrade: String?
    var selectedDate: Date?
    
    var completedComponents: Int?
    
    let dateFormatter = DateFormatter()
    
    var grades: Grade?
    
    var resultsArray = [Int]()
    
    var resultSet = [Result]()
    
    @IBOutlet weak var saveSetButton: UIButton!
    @IBOutlet weak var disabledSaveSetButton: UIButton!
    @IBOutlet weak var disabledSaveButtonBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var enabledSaveButtonBtmConstraint: NSLayoutConstraint!
    
    var backgroundColor: UIColor?
    
    var blurEffectView: UIVisualEffectView?
    @IBOutlet weak var componentsTableView: UITableView!
    
    let realm = try! Realm()
    
    var results: Results<Result> {
        get {
            return try! Realm().objects(Result.self).filter("qualification == '\(selectedQual!)'")
        }
    }
    
    var components: Results<Component> {
        get {
            return try! Realm().objects(Component.self).filter("qualification == '\(selectedQual!)'")
        }
    }
    
    var qualifications: Results<Qualification> {
        get {
            return try! Realm().objects(Qualification.self).filter("name == '\(selectedQual!)'")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //disableButton() *****
        enableButton()
        
        //saveResultButton.setTitleColor(backgroundColor, for: .normal)
        //datePicker.setValue(UIColor.white, forKey: "textColor")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        resultType.addTarget(self, action: #selector(resultTypeChanged), for: .touchUpInside)
        resultType.tintColor = self.backgroundColor
        
        self.title = "Input Results"
        
        populateResultsArray()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            self.disabledSaveButtonBtmConstraint.constant = keyboardHeight
            self.enabledSaveButtonBtmConstraint.constant = keyboardHeight
        }
        self.view.layoutIfNeeded();
        print(keyboardHeight);
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.disabledSaveButtonBtmConstraint.constant = 0
            self.enabledSaveButtonBtmConstraint.constant = 0
        }
        self.view.layoutIfNeeded();
    }
    
    func disableButton() {
        disabledSaveSetButton.isEnabled = false
        disabledSaveSetButton.isHidden = false
        saveSetButton.isHidden = true
    }
    
    func enableButton() {
        saveSetButton.backgroundColor = self.backgroundColor
        disabledSaveSetButton.isHidden = true
        saveSetButton.isHidden = false
    }
    
    func resultTypeChanged() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    func saveResults() {
        
        for i in 1...components.count {
            
            var resultTypeString: String?
            var convertedResult: Int?
            
            let newResult = Result()
            
            if let segmentResultType: String = resultType.titleForSegment(at: resultType.selectedSegmentIndex) {
                newResult.type = segmentResultType
                resultTypeString = segmentResultType
            }
            
            newResult.qualification = selectedQualification.name
            newResult.component = "Component \(i)"
            
            if resultTypeString == "Grade" {
                convertedResult = resultsArray[i - 1] * 10
            } else {
                convertedResult = resultsArray[i - 1]
            }
            
            newResult.result = convertedResult!
            
            //     newResult.date = datePicker.date
            newResult.set = (results.count / components.count) + 1
            
            resultSet.append(newResult)
            
            if resultsArray.count == components.count {
                enableButton()
            }
            componentsTableView.reloadData()
        }
    }
    
    @IBAction func exitView(_ sender: UIButton) {
    }
    
    @IBAction func saveResultSet(_ sender: UIButton) {
        
        saveResults()
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(resultSet)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadResults"), object: nil)
        
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewValueChange(sender: UITextField) {
        
        let currentValue = Int(sender.text!)
        let textRow = sender.tag
        
        resultsArray.remove(at: textRow)
        resultsArray.insert(currentValue!, at: textRow)
        
        print(textRow)
        print(resultsArray)
        
    }
    
    func populateResultsArray() {
        for _ in 1...components.count {
            resultsArray.append(0)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell4", for: indexPath) as! CustomTableViewCell
        
        let component = components[(indexPath as NSIndexPath).row]
        
        if indexPath.row == completedComponents {
        //cell.accessoryType = .checkmark
        }
        
        cell.labelOutlet?.text = component.name
        cell.placeholderTextOutlet.tag = indexPath.row
        cell.placeholderTextOutlet.addTarget(self, action: #selector(textViewValueChange), for: .editingChanged)
        cell.placeholderTextOutlet.keyboardType = UIKeyboardType.numberPad
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        resultTextField.text = ""
//        weightingTextField.text = ""
//        completedComponents = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedComponent = components[indexPath.row]
        return indexPath
    }
    
}

