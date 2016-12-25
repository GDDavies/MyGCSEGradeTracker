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
        
        navigationController?.navigationBar.topItem?.title = "Manage"
        navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissView))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
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

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let qualToDelete = qualifications[indexPath.row].name
            
            let alertController = UIAlertController(title: "Warning!", message: "This action will delete all results and components associated with this qualification.", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                
                tableView.beginUpdates()
                //delete from your datasource!
                
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
                
                try! self.realm.write {
                    self.realm.delete(deletedQualification)
                    self.realm.delete(deletedResults)
                    self.realm.delete(deletedComponents)
                }
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
                //this is optional, it makes the delete button go away on the cell
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
            alertController.addAction(delete)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation
    
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
         if segue.identifier == "ShowSets" {
            let controller = segue.destination as! ManageSetsTableViewController
            let row = self.tableView.indexPathForSelectedRow?.row
            controller.selectedQualification = qualifications[row!]
        }
     }
}
