//
//  ManageQualificationsTableViewController.swift
//  MyGCSEGradeTracker
//
//  Created by George Davies on 12/12/2016.
//  Copyright © 2016 George Davies. All rights reserved.
//

import UIKit
import RealmSwift

class ManageQualificationsTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    lazy var qualifications: Results<Qualification> = { self.realm.objects(Qualification.self) }()
    
    var selectedQualification: Qualification!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        navigationController?.navigationBar.topItem?.title = "Manage Qualifications"
        navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        print(qualifications)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return qualifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCell", for: indexPath)
        
        let qualification = qualifications[indexPath.row]

        // Configure the cell...
        
        cell.textLabel?.text = qualification.name
        cell.detailTextLabel?.text = "\(qualification.numberOfComponents) components"
        return cell
    }

//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //realm.refresh()
            
            let qualToDelete = qualifications[indexPath.row].name
            
            var deletedQualification: Results<Qualification> {
                get {
                    return try! Realm().objects(Qualification.self).filter("name == '\(qualToDelete)'")
                }
            }
            
            var deletedResults: Results<Result> {
                get {
                    return try! Realm().objects(Result.self).filter("qualification == '\(qualToDelete)'")
                }
            }
            
            var deletedComponents: Results<Component> {
                get {
                    return try! Realm().objects(Component.self).filter("qualification == '\(qualToDelete)'")
                }
            }
            
            try! realm.write {
                realm.delete(deletedQualification)
                realm.delete(deletedResults)
                realm.delete(deletedComponents)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
         if segue.identifier == "ShowResults" {
            
//            let path = self.tableView.indexPathForSelectedRow
//            let vc = segue.destination as! ManageResultsTableViewController
//             
//            vc.selectedQualification = qualifications[(path?.row)!]
            
            let controller = segue.destination as! ManageResultsTableViewController
            let row = self.tableView.indexPathForSelectedRow?.row
            controller.selectedQualification = qualifications[row!]
        }
     }

}
