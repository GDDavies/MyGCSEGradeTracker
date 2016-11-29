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
    
    @IBOutlet weak var weightingTextField: UITextField!
    var selectedGrade: String?
    var selectedDate: Date?
    
    var completedComponents: Int?
    
    let dateFormatter = DateFormatter()
    
    var grades: Grade?
    
    var resultSet = [Result]()
    
    @IBOutlet weak var componentAddResultTextOutlet: UILabel!
    @IBOutlet weak var resultTextField: UITextField!
    
    @IBOutlet var inputResultsViewContoller: UIView!
    
    @IBOutlet weak var saveResultButton: UIButton!
    @IBOutlet weak var saveSetButton: UIButton!
    @IBOutlet weak var disabledSaveSetButton: UIButton!
    var backgroundColor: UIColor?
    
    @IBOutlet weak var datePicker: UIDatePicker!
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
        
        disableButton()
        
        inputResultsViewContoller.backgroundColor = backgroundColor
        saveResultButton.setTitleColor(backgroundColor, for: .normal)
        datePicker.setValue(UIColor.white, forKey: "textColor")
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
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    @IBAction func saveResult(_ sender: UIButton) {
        
        var resultTypeString: String?
        let resultInt = Int(resultTextField.text!)!
        var convertedResult: Int?
        
        // Remove previously entered result for unit
        if let indexOfComponent = resultSet.index(where:{$0.component == selectedComponent.name}) {
        
            resultSet.remove(at: indexOfComponent)
        }
        
        let newResult = Result()
        
        if let segmentResultType: String = resultType.titleForSegment(at: resultType.selectedSegmentIndex) {
            newResult.type = segmentResultType
            resultTypeString = segmentResultType
        }
        
        newResult.qualification = selectedQualification.name
        newResult.component = selectedComponent.name
        
        if resultTypeString == "Grade" {
            convertedResult = resultInt * 10
        } else {
            convertedResult = resultInt
        }
            
        newResult.result = convertedResult!
        
        newResult.date = datePicker.date
        newResult.weighting = (Double(weightingTextField.text!)!) / 100
        newResult.set = (results.count / components.count) + 1
        
        resultSet.append(newResult)
        
        if resultSet.count == components.count {
            enableButton()
        }
        componentsTableView.reloadData()
        animateOut()
    }
    
    @IBAction func exitView(_ sender: UIButton) {
        animateOut()
    }
    
    @IBAction func saveResultSet(_ sender: UIButton) {
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QualificationComponents", for: indexPath) as! ResultsSetTableViewCell
        
        let component = components[(indexPath as NSIndexPath).row]
        
        if indexPath.row == completedComponents {
        cell.cellImageView?.image = UIImage(named: "success")
        }
        
        cell.cellLabel?.text = component.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultTextField.text = ""
        weightingTextField.text = ""
        completedComponents = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        animateIn()
        selectedComponent = components[indexPath.row]
        return indexPath
    }
    
    func animateIn() {
        blur()
        
        self.view.addSubview(inputResultsViewContoller)
        
        inputResultsViewContoller.center = CGPoint(x: view.frame.size.width / 2, y: (view.frame.size.height / 2) - 50.0) //self.view.center
        
        inputResultsViewContoller.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        inputResultsViewContoller.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            // visual effect view here
            
            self.inputResultsViewContoller.alpha = 1
            self.inputResultsViewContoller.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.inputResultsViewContoller.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.inputResultsViewContoller.alpha = 0
            
        }) { (success:Bool) in
            self.inputResultsViewContoller.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
        }
    }
    
    func blur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView!)
    }

}

