//
//  QualificationsViewController.swift
//  My Grade Tracker
//
//  Created by George Davies on 19/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class QualificationsViewController: UIViewController {
    
    var selectedQualification: Qualification!
    var selectedQual: String?
    var selectedComponent: Component!
    
    var setResultsArray = [Double]()
    
    var backgroundColor: UIColor?
    
    var sourceCell: CustomQualificationCollectionViewCell?
    
    var backgrounColor: UIColor?
    
    let target = 70.0
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var createSetButton: UIButton!
    
    @IBOutlet weak var numberOfResultsTextLabel: UILabel!
    @IBOutlet weak var averageGradeTextLabel: UILabel!
    @IBOutlet weak var averagePercentageTextLabel: UILabel!

    @IBOutlet weak var statsBox: UIView!
    @IBOutlet weak var setsOfResultsLabel: UILabel!
    @IBOutlet weak var averageGradeLabel: UILabel!
    @IBOutlet weak var averagePercentageLabel: UILabel!
    
    var averageGrade: String?
    var averagePercentage: String?
    
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
        
        createSetButton.backgroundColor = backgroundColor
        //statsBox.backgroundColor = backgroundColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadResults(_:)), name: NSNotification.Name(rawValue: "loadResults"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createSets()
        //setsOfResultsLabel.text = String(results.count / components.count)
        averageGradeCalc()
        averagePercentageCalc()
        //averageGradeLabel.text = averageGrade!
       // averagePercentageLabel.text = averagePercentage!
        setChart(values: setResultsArray)
        self.lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 1.5)
    }
    
    func setChart(values: [Double]) {
        
        let mappedResults = values.enumerated().map { x, y in return ChartDataEntry(x: Double(x+1), y: y) }

        let data = LineChartData()
        let resultsData = LineChartDataSet(values: mappedResults, label: "")
        
        // Format lines and circles
        resultsData.colors = [UIColor.black]
        resultsData.lineWidth = 2
        resultsData.circleColors = [UIColor.black]
        resultsData.circleHoleColor = UIColor.black
        resultsData.circleRadius = 5
        
        // format numbers on line
        let lineValueFormatter = NumberFormatter()
        lineValueFormatter.generatesDecimalNumbers = false
        lineValueFormatter.positiveSuffix = "%"
        resultsData.valueFormatter = DefaultValueFormatter(formatter: lineValueFormatter)
        
        // format left axis numbers
        let leftAxisValueFormatter = NumberFormatter()
        leftAxisValueFormatter.generatesDecimalNumbers = false
        leftAxisValueFormatter.positiveSuffix = "%"
        lineChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisValueFormatter)
        
        // format x axis numbers
        let xAxisValueFormatter = NumberFormatter()
        xAxisValueFormatter.generatesDecimalNumbers = false
        xAxisValueFormatter.positivePrefix = "Set "
        lineChartView.xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: xAxisValueFormatter)
        
        if values.count >= 2 {
            // Add data to chart
            data.addDataSet(resultsData)
            lineChartView.data = data
        } else {
            // Don't add data
            lineChartView.noDataText = "Please provide at least two results sets for the chart."
        }
        
        // Target line
        let trgt = ChartLimitLine(limit: target, label: "Target: \(target)%")
        lineChartView.leftAxis.addLimitLine(trgt)
        
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 100
        
        lineChartView.xAxis.axisMinimum = 1
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.gridColor = UIColor.white
        
        lineChartView.legend.enabled = false
        lineChartView.chartDescription?.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func averageGradeCalc() {
        var sum = 0.0
        for i in 0..<setResultsArray.count {
            sum += round(setResultsArray[i] / 10)
            print(sum)
        }
        let fmt = NumberFormatter()
        fmt.maximumIntegerDigits = 1
        let output = sum / (Double(results.count) / Double(components.count))
        averageGrade = fmt.string(from: NSNumber(value: output))
    }
    
    func averagePercentageCalc() {
        var sum = 0.0
        for i in 0..<setResultsArray.count {
            sum += setResultsArray[i]
            print(sum)
        }
        print(setResultsArray)
        let fmt = NumberFormatter()
        fmt.maximumIntegerDigits = 2
        let output = round(sum / (Double(results.count) / Double(components.count)))
        averagePercentage = fmt.string(from: NSNumber(value: output))
        print("av % \(averagePercentage)")
    }
    
    func loadResults(_ notification: Foundation.Notification){

        print("Results loaded")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateSet" {
            
            let svc = segue.destination as? UINavigationController
            
            let controller = svc?.topViewController as! ResultsSetViewController
            
            controller.selectedQual = selectedQual
            controller.selectedQualification = selectedQualification
            controller.selectedComponent = selectedComponent
            controller.backgroundColor = backgroundColor
        }
    }
    
    func createSets() {
        
        if setResultsArray.count > 0 {
            setResultsArray.removeAll()
        }
        
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
                
                let weightedResult = Double(setResults[x].result) * components[x].weighting
                
                addResults += weightedResult
                x += 1
            }
            setResultsArray.append(addResults)
            i += 1

            addResults = 0
        }
        print("Results set array \(setResultsArray)")
    }
}

