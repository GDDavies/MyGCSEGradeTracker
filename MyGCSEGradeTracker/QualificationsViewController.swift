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
        
        //if let navController = self.navigationController {
           // navController.navigationBar.tintColor = UIColor.white
           // navController.navigationBar.barTintColor = backgroundColor
           // navController.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 24)!, NSForegroundColorAttributeName: UIColor.white]

        //}
        
//        createSets()
//        setChart(values: setResultsArray)
//        addChart()
        
//        selectedQualView.backgroundColor = backgroundColor
//        selectedQualificationLabel.text = selectedQualification.name
        
        createSetButton.backgroundColor = backgroundColor
        statsBox.backgroundColor = backgroundColor
        
        
        
        setsOfResultsLabel.text = String(results.count / components.count)
        averageGradeCalc()
        averagePercentageCalc()
        averageGradeLabel.text = averageGrade!
        averagePercentageLabel.text = averagePercentage!
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadResults(_:)), name: NSNotification.Name(rawValue: "loadResults"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(1)
        print(setResultsArray)
        //lineChartView.notifyDataSetChanged()
        createSets()
        setChart(values: setResultsArray)
    }
    
    func setChart(values: [Double]) {
        
        let mappedResults = values.enumerated().map { x, y in return ChartDataEntry(x: Double(x+1), y: y) }
        
        let data = LineChartData()
        let resultsData = LineChartDataSet(values: mappedResults, label: "")
        
        print(mappedResults)
        print(resultsData)
        
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
        
        //        var i = 0
        //
        //        while i <= 100 {
        //            let boundaries = ChartLimitLine(limit: (Double(i) * 10), label: "\(i)")
        //            lineChartView.leftAxis.addLimitLine(boundaries)
        //            i += 10
        //        }
        
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
        let fmt = NumberFormatter()
        fmt.maximumIntegerDigits = 2
        let output = round(sum / (Double(results.count) / Double(components.count)))
        averagePercentage = fmt.string(from: NSNumber(value: output))
    }
    
    func loadResults(_ notification: Foundation.Notification){
        
//        var xValues = [Double]()
//        var i = 1
//        while i - 1 < setResultsArray.count {
//            xValues.append(Double(i))
//            i += 1
//        }
//        let zipped = Array(zip(xValues, setResultsArray))
//                
//        lineChart.add(ChartSeries(data: zipped))
        

        
        print("Results loaded")
    }

//    func addChart() {
//        
//        if setResultsArray.isEmpty {
//            print("Array is empty")
//        }else{
//            var xValues = [Double]()
//            var i = 1
//            while i - 1 < setResultsArray.count {
//                xValues.append(Double(i))
//                i += 1
//            }
//            let zipped = Array(zip(xValues, setResultsArray))
//            
//            print("Zipped = \(zipped)")
//            
//            let data = zipped
//            let series = ChartSeries(data: data)
//            series.color = backgroundColor!
//            lineChart.add(series)
//        }
//        
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateSet" {
            
            let svc = segue.destination as? UINavigationController
            
            let controller = svc?.topViewController as! ResultsSetViewController
            
           // if let destinationVC = segue.destination as? ResultsSetViewController {
                controller.selectedQual = selectedQual
                controller.selectedQualification = selectedQualification
                controller.selectedComponent = selectedComponent
                controller.backgroundColor = backgroundColor
          //  }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

