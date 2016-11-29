//
//  ResultsSetTableViewCell.swift
//  My Grade Tracker
//
//  Created by George Davies on 20/10/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit

class ResultsSetTableViewCell: UITableViewCell {
    
    var screenWidth: CGFloat!
    var screenSize: CGRect!

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        
//        let scale = CGFloat(max(screenSize.width/30, screenSize.height/30))
//        let width:CGFloat  = 30 * scale
//        let height:CGFloat = 30 * scale;

//        self.imageView?.frame = CGRect(x: screenWidth - 50, y: 10, width: 30, height: 30)
    }

}
