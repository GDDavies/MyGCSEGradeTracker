//
//  TableViewCell.swift
//  MyGradeTarckerV2
//
//  Created by George Davies on 03/11/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var placeholderTextOutlet: UITextField!
    @IBOutlet weak var labelOutlet: UILabel!
    
    var activeTextField = UITextField()
    var textFieldText = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
