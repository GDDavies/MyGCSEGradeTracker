//
//  Grade.swift
//  My Grade Tracker
//
//  Created by George Davies on 16/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import Foundation

class Grade: NSObject {
    var ums: Int
    var date: String
    
    init(ums: Int, date: String) {
        self.ums = ums
        self.date = date
    }
}
