//
//  ManageSetsTableViewController.swift
//  MyGCSEGradeTracker
//
//  Created by George Davies on 20/12/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift

class ManageSetsTableViewController: UITableViewController {
        
    var selectedQualification: Qualification!
    var selectedQual: String?
    var numberOfSets: Int?
    
    let realm = try! Realm()
    
    var results: Results<Result> {
        get {
            return try! Realm().objects(Result.self).filter("qualification == '\(selectedQualification.name)'")
        }
    }
    
    var components: Results<Component> {
        get {
            return try! Realm().objects(Component.self).filter("qualification == '\(selectedQualification.name)'")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedQualification.name
        navigationItem.rightBarButtonItem = self.editButtonItem
        numberOfSets = results.count / components.count
        reorderSets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reorderSets() {
        // get sets only, work on full set rather than individual results
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfSets!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var setResults: Results<Result> {
            get {
                return try! Realm().objects(Result.self).filter("qualification == '\(selectedQualification.name)' AND set == \(indexPath.row + 1)")
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetCell", for: indexPath)
                
        cell.textLabel?.text = "Set \(indexPath.row + 1)"
        
        var detailResultsArray = ""
        
        for result in setResults {
            detailResultsArray += String(result.result) + "% "
        }
        
        cell.detailTextLabel?.text = "\(detailResultsArray)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let chosenSet = results[indexPath.row].set
            
            var editedResults: Results<Result> {
                get {
                    return try! Realm().objects(Result.self).filter("qualification == '\(selectedQualification.name)' AND set == \(results[indexPath.row].set)")
                }
            }
            
            try! realm.write {
                realm.delete(editedResults)
            }
            numberOfSets = results.count / components.count
            
            
            for result in results {
                if result.set > chosenSet {
                    result.set -= 1
                }
            }
            
            
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func addTarget() {
        
        print("target added")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowResults" {
            
            //            let path = self.tableView.indexPathForSelectedRow
            //            let vc = segue.destination as! ManageResultsTableViewController
            //
            //            vc.selectedQualification = qualifications[(path?.row)!]
            
            let controller = segue.destination as! ManageResultsTableViewController
            let row = self.tableView.indexPathForSelectedRow?.row
            controller.selectedQualification = selectedQualification
            controller.selectedSet = row! + 1
        }
    }

    
}
