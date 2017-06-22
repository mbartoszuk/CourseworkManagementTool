//
//  MasterViewController.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 20/04/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        // self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newCoursework = Coursework(context: context)
             
        // If appropriate, configure the new managed object.
        newCoursework.coursework_name = "Group Project"

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.detailItemContext = self.fetchedResultsController.managedObjectContext
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "popoverToAddCoursework" {
            segue.destination.popoverPresentationController?.delegate =
                (segue.destination as! AddCourseworkViewController)
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let coursework = self.fetchedResultsController.object(at: indexPath)
        self.configureCell(cell, withCoursework: coursework)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withCoursework coursework: Coursework) {
        cell.textLabel!.text = coursework.coursework_name
        let view = cell.contentView.superview as! CourseworkTableCellView
        let due = coursework.coursework_due_date
        view.label_dueDate.text = format().string(from: due as! Date)
        
        // Time interval is in seconds.
        let daysLeft = Int(floor(due!.timeIntervalSinceNow / (24 * 60 * 60)))
        // Setting the appropriate labels.
        if daysLeft < 0 {
            view.label_daysLeft.text = "complete"
        } else {
            view.label_daysLeft.text = "\(daysLeft) days left"
        }
        
        // Colouring the completeness labels based on the current status.
        if daysLeft < 0 {
            view.label_daysLeft.textColor = UIColor(red: 0x8B/255, green: 0xC3/255, blue: 0x4A/255, alpha: 1.0)
        } else if daysLeft <= 7 {
            view.label_daysLeft.textColor = UIColor(red: 0x9E/255, green: 0x0B/255, blue: 0x0F/255, alpha: 1.0)
        } else {
            view.label_daysLeft.textColor = UIColor(red: 0x3F/255, green: 0x51/255, blue: 0xB5/255, alpha: 1.0)
        }
        
        // Filling out the module name if one was assigned in the form.
        if let moduleName = coursework.module_name {
            view.label_moduleName.text = moduleName
        } else {
            view.label_moduleName.text = ""
        }
    }
    
    // Used to format the date for the any date picker.
    func format() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        return df;
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Coursework> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Coursework> = Coursework.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "coursework_due_date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Coursework>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.configureCell(tableView.cellForRow(at: indexPath!)!, withCoursework: anObject as! Coursework)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */
}
