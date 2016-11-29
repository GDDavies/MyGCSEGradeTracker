//
//  Result.swift
//  My Grade Tracker
//
//  Created by George Davies on 16/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import Foundation
import RealmSwift

class Result: Object {
    dynamic var result = 0
    dynamic var type = ""
    dynamic var date = Date()
    dynamic var qualification = ""
    dynamic var component = ""
    dynamic var weighting = 0.0
    dynamic var set = 0
}
