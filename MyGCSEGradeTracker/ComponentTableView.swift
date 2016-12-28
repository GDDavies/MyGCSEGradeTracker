//
//  ComponentTableView.swift
//  MyGradeTarckerV2
//
//  Created by George Davies on 03/11/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit

class ComponentTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    var numberOfComponents: Int?
    
    var textViewOutput = [String?]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.delegate = self
    
        if let numOfComps = numberOfComponents {
            for _ in 1...numOfComps {
                textViewOutput.append("")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if numberOfComponents == nil {
            return "Please enter number of components"
        }
        return "Component Details"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let numOfComps = numberOfComponents{
            return numOfComps
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: CustomTableViewCell?
        var arr = [String]()
        
        for i in 1...numberOfComponents! {
            
            arr.append("Component \(i)")
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: "Cell3") as! CustomTableViewCell?
        
        cell?.labelOutlet.text = arr[indexPath.row]
        cell?.placeholderTextOutlet.placeholder = "e.g. \(100 / numberOfComponents!)%"

        cell?.selectionStyle = .none
        cell?.placeholderTextOutlet.keyboardType = UIKeyboardType.decimalPad
        
        cell?.placeholderTextOutlet.tag = indexPath.row
        cell?.placeholderTextOutlet.addTarget(self, action: #selector(textViewValueChange), for: .editingChanged)
        
        return cell!
    }
    
    func textViewValueChange(sender: UITextField) {
        
        let currentValue = sender.text
        let textRow = sender.tag
        
        textViewOutput.remove(at: textRow)
        textViewOutput.insert(currentValue!, at: textRow)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            print("Cell 3 tapped")
            
        default:
            break
        }
    }
}
