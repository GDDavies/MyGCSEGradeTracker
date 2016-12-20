//
//  ManageResultsTableViewController.swift
//  MyGCSEGradeTracker
//
//  Created by George Davies on 12/12/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift

class ManageResultsTableViewController: UITableViewController {
    
    var selectedQualification: Qualification!
    var selectedSet: Int?
    var selectedQual: String?
    
    let realm = try! Realm()
    
    var results: Results<Result> {
        get {
            return try! Realm().objects(Result.self).filter("qualification == '\(selectedQualification.name)' AND set == \(selectedSet!)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Set \(selectedSet!)"
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
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)

        let result = results[indexPath.row]
        
        cell.textLabel?.text = result.component
        cell.detailTextLabel?.text = "Result: \(result.result)%"

        return cell
    }
}
