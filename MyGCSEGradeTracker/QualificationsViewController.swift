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
    var target: Double?
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    let percentVar3 = 90.0
    let animationDuration = 1.5
    
    @IBOutlet weak var progressView: KDCircularProgress!
    @IBOutlet weak var progressView2: KDCircularProgress!
    @IBOutlet weak var progressView3: KDCircularProgress!
    @IBOutlet weak var progressView4: KDCircularProgress!
    @IBOutlet weak var progressView5: KDCircularProgress!
    @IBOutlet weak var progressView6: KDCircularProgress!
    
    @IBOutlet weak var percentLabel: SACountingLabel!
    @IBOutlet weak var percentLabel2: SACountingLabel!
    @IBOutlet weak var percentLabel3: SACountingLabel!
    @IBOutlet weak var percentLabel4: SACountingLabel!
    @IBOutlet weak var percentLabel5: SACountingLabel!
    @IBOutlet weak var percentLabel6: SACountingLabel!
    
    @IBOutlet weak var averageGradeLabel: UILabel!
    @IBOutlet weak var averagePercentLabel: UILabel!
    @IBOutlet weak var numberOfSets: UILabel!
    @IBOutlet weak var diffFromTarget: UILabel!
    @IBOutlet weak var averageLastThree: UILabel!
    @IBOutlet weak var changeLastThree: UILabel!
    
    var averageGrade: String?
    var doubleAverageGrade: Double?
    var averagePercentage: String?
    var doubleAveragePercentage: Double?
    
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
        _ = averageGradeCalc()
        _ = averagePercentageCalc()
        setupProgressViews()
        
        percentLabel.textColor = UIColor.white
        percentLabel2.textColor = UIColor.white
        percentLabel3.textColor = UIColor.white
        percentLabel4.textColor = UIColor.white
        percentLabel5.textColor = UIColor.white
        percentLabel6.textColor = UIColor.white
        
        averageGradeLabel.textColor = UIColor.white
        averagePercentLabel.textColor = UIColor.white
        numberOfSets.textColor = UIColor.white
        diffFromTarget.textColor = UIColor.white
        averageLastThree.textColor = UIColor.white
        changeLastThree.textColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Results", style: .plain, target: self, action: #selector(addResultsTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createSets()
        setChart(values: setResultsArray)
        self.lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 1.5)
    }
    
    func addResultsTapped() {
        performSegue(withIdentifier: "AddResults", sender: self)
    }
    
    func setChart(values: [Double]) {
        let mappedResults = values.enumerated().map { x, y in return ChartDataEntry(x: Double(x+1), y: y) }
        let data = LineChartData()
        let resultsData = LineChartDataSet(values: mappedResults, label: "")
        
        // Format lines and circles
        resultsData.colors = [UIColor.white]
        resultsData.lineWidth = 2
        resultsData.circleColors = [backgroundColor!]
        resultsData.circleHoleColor = backgroundColor
        resultsData.circleRadius = 0
        resultsData.valueFont = UIFont(name: "HelveticaNeue-Bold", size: 8)!
        resultsData.valueTextColor = UIColor.white
        resultsData.highlightColor = UIColor.white
        
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
            lineChartView.noDataText = "Please provide at least two sets of results for the chart."
        }
        
        // Target line
        if let newTarget = target {
            let trgt = ChartLimitLine(limit: newTarget, label: "") //Target: \(target)%
            lineChartView.leftAxis.addLimitLine(trgt)
        }
        
        lineChartView.highlightPerTapEnabled = false
        lineChartView.backgroundColor = backgroundColor
        
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.axisLineColor = backgroundColor!
        lineChartView.extraLeftOffset = 10
        lineChartView.extraRightOffset = 40
        lineChartView.extraTopOffset = 40
        lineChartView.extraBottomOffset = 30
        
        lineChartView.lineData?.setDrawValues(true)
        
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.leftAxis.axisLineColor = backgroundColor!
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 100
        lineChartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 12)!
        lineChartView.leftAxis.labelTextColor = UIColor.white
        lineChartView.leftAxis.gridColor = UIColor.white

        lineChartView.xAxis.axisMinimum = 1
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.gridColor = backgroundColor!
        lineChartView.xAxis.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 12)!
        lineChartView.xAxis.labelTextColor = UIColor.white
        
        lineChartView.legend.enabled = false
        lineChartView.chartDescription?.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddResults" {
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
    }
    
    // MARK Stats Box
    func setupProgressViews(){
        progressView.set(colors: backgroundColor!)
        progressView2.set(colors: backgroundColor!)
//       progressView3.set(colors: backgroundColor!)
//        progressView4.set(colors: backgroundColor!)
        progressView5.set(colors: backgroundColor!)
        progressView6.set(colors: backgroundColor!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if results.count != 0 {
            let angle = convertToAngle(grade: Double(averageGradeCalc()!)!)
            let angle2 = convertToAngle2(percent: averagePercentageCalc()!)
 //           let angle3 = convertToAngle2(percent: percentVar3)
//            let angle4 = 90
            let angle5 = 270
            let angle6 = 180

            progressView.animate(toAngle: angle!, duration: 1.6, completion: nil)
            progressView2.animate(toAngle: angle2!, duration: 1.6, completion: nil)
//            progressView3.animate(toAngle: angle3!, duration: 1.6, completion: nil)
//            progressView4.animate(toAngle: Double(angle4), duration: 1.6, completion: nil)
            progressView5.animate(toAngle: Double(angle5), duration: 1.6, completion: nil)
            progressView6.animate(toAngle: Double(angle6), duration: 1.6, completion: nil)
            incrementLabel(to: Double(averageGradeCalc()!)!, secondEndValue: averagePercentageCalc()!, thirdEndValue: percentVar3, fourthEndValue: 25.0, fifthEndValue: 75.0, sixthEndValue: 50.0)
        }
    }
    
    func convertToAngle(grade: Double) -> Double? {
        let angle = (grade * 10) * 3.6
        return angle
    }
    
    func convertToAngle2(percent: Double) -> Double? {
        let angle = percent * 3.6
        return angle
    }
    
    func incrementLabel(to firstEndValue: Double, secondEndValue: Double, thirdEndValue: Double, fourthEndValue: Double, fifthEndValue: Double, sixthEndValue: Double) {
        percentLabel.countFrom(fromValue: 0, to: Float(firstEndValue), withDuration: animationDuration, andAnimationType: .Linear, andCountingType: .Int)
        percentLabel2.format = "%.0f%%"
        percentLabel2.countFrom(fromValue: 0, to: Float(secondEndValue), withDuration: animationDuration, andAnimationType: .Linear, andCountingType: .Custom)
//        percentLabel3.format = "%.0f%%"
        percentLabel3.countFrom(fromValue: 0, to: Float(thirdEndValue), withDuration: animationDuration, andAnimationType: .Linear, andCountingType: .Int)
        percentLabel4.format = "+%.0f%"
        percentLabel4.countFrom(fromValue: 0, to: Float(fourthEndValue), withDuration: animationDuration, andAnimationType: .Linear, andCountingType: .Custom)
        percentLabel5.format = "%.0f%%"
        percentLabel5.countFrom(fromValue: 0, to: Float(fifthEndValue), withDuration: animationDuration, andAnimationType: .Linear, andCountingType: .Custom)
        percentLabel6.format = "%.0f%%"
        percentLabel6.countFrom(fromValue: 0, to: Float(sixthEndValue), withDuration: animationDuration, andAnimationType: .Linear, andCountingType: .Custom)
    }
    
    // MARK: Stats labels functions
    func averageGradeCalc() -> String? {
        var sum = 0.0
        for i in 0..<setResultsArray.count {
            sum += round(setResultsArray[i] / 10)
        }
        let fmt = NumberFormatter()
        fmt.maximumIntegerDigits = 1
        let output = sum / (Double(results.count) / Double(components.count))
        averageGrade = fmt.string(from: NSNumber(value: output))
        return averageGrade
    }
    
    func averagePercentageCalc() -> Double? {
        var sum = 0.0
        for i in 0..<setResultsArray.count {
            sum += setResultsArray[i]
        }
        let fmt = NumberFormatter()
        fmt.maximumIntegerDigits = 2
        let output = round(sum / (Double(results.count) / Double(components.count)))
        averagePercentage = fmt.string(from: NSNumber(value: output))
        return output
    }
    
    func averageLastThreeCalc() -> Double {
        return 0.0
    }
    
    func lastThreeChange() {
        
    }
}

