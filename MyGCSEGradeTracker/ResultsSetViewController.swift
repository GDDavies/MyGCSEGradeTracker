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
    
    //var resultsDictionary = [Int]()
    
    var resultsDictionary: [Int:Int] = [:]
    
    var resultSet = [Result]()
    
    @IBOutlet weak var saveSetButton: UIButton!
    @IBOutlet weak var enabledSaveButtonBtmConstraint: NSLayoutConstraint!
    
    var backgroundColor: UIColor?
    
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
    
    @IBAction func cancelAddResults(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        resultType.tintColor = self.backgroundColor
        saveSetButton.backgroundColor = self.backgroundColor
        self.title = "Input Results"
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.animate(withDuration: 0.3) {
            self.enabledSaveButtonBtmConstraint.constant = keyboardHeight
        }
        self.view.layoutIfNeeded();
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.enabledSaveButtonBtmConstraint.constant = 0
        }
        self.view.layoutIfNeeded();
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
            if resultTypeString == "Grade" {
                convertedResult = resultsDictionary[i - 1]! * 10
            } else {
                convertedResult = resultsDictionary[i - 1]
            }
            newResult.qualification = selectedQualification.name
            newResult.component = "Component \(i)"
            newResult.result = convertedResult!
            newResult.set = (results.count / components.count) + 1
            
            resultSet.append(newResult)
            componentsTableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveResultSet(_ sender: UIButton) {
        if resultsDictionary.count == components.count {
            saveResults()
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(resultSet)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadResults"), object: nil)
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter a result for each component", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewValueChange(sender: UITextField) {
        
        let currentValue = Int(sender.text!)
        let textRow = sender.tag
        
        resultsDictionary.removeValue(forKey: textRow)
        
        if let unwrappedValue = currentValue {
            resultsDictionary[textRow] = unwrappedValue
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell4", for: indexPath) as! CustomTableViewCell
        let component = components[(indexPath as NSIndexPath).row]
        
        cell.labelOutlet?.text = component.name
        cell.placeholderTextOutlet.tag = indexPath.row
        cell.placeholderTextOutlet.addTarget(self, action: #selector(textViewValueChange), for: .editingChanged)
        cell.placeholderTextOutlet.keyboardType = UIKeyboardType.numberPad
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedComponent = components[indexPath.row]
        return indexPath
    }
    
}

