//
//  ManageSetsTableViewController.swift
//  MyGCSEGradeTracker
//
//  Created by George Davies on 20/12/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift
import Flurry_iOS_SDK

class ManageSetsTableViewController: UITableViewController {
        
    var selectedQualification: Qualification!
    var selectedQual: String?
    var numberOfSets: Int?
    
    let realm = try! Realm()
    
    var results: Results<Result> {
        get {
            return try! Realm().objects(Result.self).filter("qualification == %@", selectedQualification.name)
        }
    }
    
    var components: Results<Component> {
        get {
            return try! Realm().objects(Component.self).filter("qualification == %@", selectedQualification.name)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedQualification.name
        navigationItem.rightBarButtonItem = self.editButtonItem
        numberOfSets = results.count / components.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                return try! Realm().objects(Result.self).filter("qualification == %@ AND set == %d", selectedQualification.name, indexPath.row + 1)
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetCell", for: indexPath)
                
        cell.textLabel?.text = "\(NSLocalizedString("Set", comment: "")) \(indexPath.row + 1)"
        cell.detailTextLabel?.text = formattedSetDate(date: setResults[0].date)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let chosenSet = indexPath.row + 1
            
            var editedResults: Results<Result> {
                get {
                    return try! Realm().objects(Result.self).filter("qualification == %@ AND set == %d", selectedQualification.name, indexPath.row + 1)
                }
            }
            var i = 0
            while i == 0 {
                i += 1
            }
            
            try! realm.write {
                Flurry.logEvent("Deleted-Set")
                realm.delete(editedResults)
                for result in results {
                    if result.set > chosenSet {
                        result.set -= 1
                    }
                }
            }
            numberOfSets = results.count / components.count
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowResults" {
            let controller = segue.destination as! ManageResultsTableViewController
            let row = self.tableView.indexPathForSelectedRow?.row
            controller.selectedQualification = selectedQualification
            controller.selectedSet = row! + 1
        }
    }
    
    func formattedSetDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}
