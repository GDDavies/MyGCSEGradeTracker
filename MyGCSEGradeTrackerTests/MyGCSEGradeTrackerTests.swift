//
//  MyGCSEGradeTrackerTests.swift
//  MyGCSEGradeTrackerTests
//
//  Created by George Davies on 29/11/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import XCTest
@testable import MyGCSEGradeTracker
import RealmSwift

class MyGCSEGradeTrackerTests: XCTestCase {
    
    var addQualViewController: AddQualificationViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        addQualViewController = AddQualificationViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testWeightingValidation() {
        let components = 4
        let weightings = [0:25,1:25,2:25,3:25]
        let weightingsValid = addQualViewController.validateWeightings(components: components, weightings: weightings)
        XCTAssertTrue(weightingsValid)
    }
    
    func testWeightingValidation2() {
        let components = 4
        let weightings = [0:25,1:25,2:25]
        let weightingsValid = addQualViewController.validateWeightings(components: components, weightings: weightings)
        XCTAssertFalse(weightingsValid)
    }
    
    func testWeightingValidation3() {
        let components = 8
        let weightings = [0:15,1:15,2:15,3:15,4:15,5:15,6:15,7:15]
        let weightingsValid = addQualViewController.validateWeightings(components: components, weightings: weightings)
        XCTAssertFalse(weightingsValid)
    }
    
    func testWeightingValidation4() {
        let components = 2
        let weightings = [0:50,1:40,2:10]
        let weightingsValid = addQualViewController.validateWeightings(components: components, weightings: weightings)
        XCTAssertFalse(weightingsValid)
    }
    
    func testWeightingValidation5() {
        let components = 2
        let weightings: Dictionary<Int,Int> = [:]
        let weightingsValid = addQualViewController.validateWeightings(components: components, weightings: weightings)
        XCTAssertFalse(weightingsValid)
    }
    
    func testWeightingValidation6() {
        let components = 8
        let weightings = [0:10,1:10,2:20,3:15,4:5,5:15,6:20,7:5]
        let weightingsValid = addQualViewController.validateWeightings(components: components, weightings: weightings)
        XCTAssertTrue(weightingsValid)
    }
    
//    func testQualNameValidation() {
//        let quals: Results<Qualification> = { realm.objects(Qualification.self) }()
//        let qualName =
//    }
}
