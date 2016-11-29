//
//  QualificationsViewController.swift
//  My Grade Tracker
//
//  Created by George Davies on 19/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftChart

class QualificationsViewController: UIViewController {
    
    var selectedQualification: Qualification!
    var selectedQual: String?
    var selectedComponent: Component!
    
    var setResultsArray = [Double]()
    
    var backgroundColor: UIColor?
    
    var sourceCell: CustomQualificationCollectionViewCell?
    
    var backgrounColor: UIColor?
    
    @IBOutlet weak var lineChart: Chart!
    
    @IBOutlet weak var createSetButton: UIButton!
    
    @IBOutlet weak var numberOfResultsTextLabel: UILabel!
    @IBOutlet weak var averageGradeTextLabel: UILabel!
    @IBOutlet weak var averagePercentageTextLabel: UILabel!

    
    
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
        
        selectedQual = selectedQualification.name
        
        backgroundColor = sourceCell?.backgroundColor
        
        self.title = selectedQual
        
        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = backgroundColor
            navController.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 24)!, NSForegroundColorAttributeName: UIColor.white]

        }
        
//        selectedQualView.backgroundColor = backgroundColor
//        selectedQualificationLabel.text = selectedQualification.name
        
        createSetButton.backgroundColor = backgroundColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadResults(_:)), name: NSNotification.Name(rawValue: "loadResults"), object: nil)
        createSets()
        addChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        
//        if let navController = self.navigationController {
//            navController.navigationBar.tintColor = UIColor.white
//            navController.navigationBar.barTintColor = backgroundColor
//            navController.navigationBar.isTranslucent = false
//            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
//        }
//        bottomBarView.backgroundColor = backgroundColor
    }
    
    func loadResults(_ notification: Foundation.Notification){
        //load data here
        
        var xValues = [Double]()
        var i = 1
        while i - 1 < setResultsArray.count {
            xValues.append(Double(i))
            i += 1
        }
        let zipped = Array(zip(xValues, setResultsArray))
                
        lineChart.add(ChartSeries(data: zipped))
        
        print("Loaded")
    }

    func addChart() {
        
        if setResultsArray.isEmpty {
            print("Array is empty")
        }else{
        var xValues = [Double]()
        var i = 1
        while i - 1 < setResultsArray.count {
            xValues.append(Double(i))
            i += 1
        }
        let zipped = Array(zip(xValues, setResultsArray))
        
        print(zipped)
        
        let data = zipped
        let series = ChartSeries(data: data)
        series.color = backgroundColor!
        lineChart.add(series)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateSet" {
            if let destinationVC = segue.destination as? ResultsSetViewController {
                destinationVC.selectedQual = selectedQual
                destinationVC.selectedQualification = selectedQualification
                destinationVC.selectedComponent = selectedComponent
                destinationVC.backgroundColor = backgroundColor
            }
        }
    }
    
    func createSets() {
        
        let numberOfSets = results.count / components.count
        var addResults = 0.0
        
        var i = 1
        
        while i <= numberOfSets {
            
            var setResults: Results<Result> {
                get {
                    return try! Realm().objects(Result.self).filter("qualification == '\(selectedQual!)' AND set == \(i)")
                }
            }
            var x = 0
            while x < components.count {
                //                setResultsArray.append(setResults[x].result)
                
                let weightedResult = Double(setResults[x].result) * setResults[x].weighting
                
                addResults += weightedResult
                x += 1
            }
            setResultsArray.append(addResults)
            i += 1
            //            setResultsArray.removeAll()
            addResults = 0
        }
        print(setResultsArray)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

