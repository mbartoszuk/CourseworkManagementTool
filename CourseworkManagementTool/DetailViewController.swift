//
//  DetailViewController.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 20/04/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,
    UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var textview_notes: UITextView!
    @IBOutlet weak var textview_markAwarded: UITextField!
    @IBOutlet weak var textview_assignedValue: UITextField!
    @IBOutlet weak var textview_level: UITextField!
    @IBOutlet weak var textview_dueDate: UITextField!
    @IBOutlet weak var textview_courseworkName: UITextField!
    @IBOutlet weak var textview_moduleName: UITextField!
    @IBOutlet weak var tableView_tasks: UITableView!
    @IBOutlet weak var tableView_reminders: UITableView!
    
    @IBOutlet weak var courseworkProgressGraphic: CourseworkProgressGraphic!
    @IBOutlet weak var label_daysUntilDue: UILabel!
    @IBOutlet weak var label_courseworkComplete: UILabel!
    
    var detailItemContext: NSManagedObjectContext?
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            textview_moduleName?.text = detail.module_name ?? ""
            textview_courseworkName?.text = detail.coursework_name ?? ""
            textview_level?.text = "\(detail.module_level)"
            if let date = detail.coursework_due_date {
                textview_dueDate?.text = format().string(from: date as Date)
        
                // Time interval is in seconds.
                let daysLeft = Int(floor(date.timeIntervalSinceNow) / (24 * 60 * 60))
                if daysLeft >= 0 {
                    label_daysUntilDue?.text = "\(daysLeft) days until due date"
                } else {
                    label_daysUntilDue?.text = "due date has passed"
                }
                
                if let create = detail.coursework_create_date {
                    let total = date.timeIntervalSince(create as Date)
                    let left = max(0, date.timeIntervalSinceNow)  // Max in case date has passed.
                    courseworkProgressGraphic?.timeElapsedRatio = CGFloat(1.0 - (left / total))
                }
            }
            textview_assignedValue?.text = "\(detail.coursework_assigned_value)"
            textview_markAwarded?.text = "\(detail.coursework_mark)"
            textview_notes?.text = detailItem?.coursework_notes ?? ""
            tableView_tasks?.reloadData()
            updateProgress()
        }
    }
    
    // Progress for the graphic.
    func updateProgress() {
        // Calculating the progress of the coursework.
        var progressValue: Float = 0
        var taskCount = 0
        for case let task as Task in detailItem?.tasks ?? [] {
            progressValue = progressValue + task.progress
            taskCount = taskCount + 1
        }
        
        // A value from 0 to 1.
        var progressAverage = progressValue / Float(taskCount)
        if progressAverage.isNaN {
            progressAverage = 0
        }
        courseworkProgressGraphic?.progressElapsedRatio = CGFloat(progressAverage)
        courseworkProgressGraphic?.setNeedsDisplay()  // Force redraw
        label_courseworkComplete?.text = "\(Int(round(progressAverage * 100)))% coursework complete"
    }
    
    // Used to format the date for any date picker.
    func format() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        return df;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textview_moduleName!.delegate = self
        textview_level!.delegate = self
        textview_courseworkName!.delegate = self
        textview_dueDate!.delegate = self
        textview_assignedValue!.delegate = self
        textview_markAwarded!.delegate = self
        textview_notes!.delegate = self
        self.configureView()
        
        // Create a date picker for the date keyboard.
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(setDueDate(sender:)), for: .valueChanged)
        textview_dueDate.inputView = datePicker
    }
    
    // Sets the text in the coursework due date field, to what is picked in the date picker.
    func setDueDate(sender: UIDatePicker) {
        textview_dueDate.text = format().string(from: sender.date)
    }

    func textViewDidChange(_ textView: UITextView) {
        updateModel()
    }
    
    // Invoked whenever text has changed in any of the details text views.
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateModel()
    }
    
    // Update of the data from the model.
    func updateModel() {
        do {
            self.detailItem?.module_name = textview_moduleName?.text
            self.detailItem?.coursework_name = textview_courseworkName?.text
            self.detailItem?.module_level = Int64(textview_level?.text ?? "") ?? 0
            if let date = textview_dueDate?.text {
                self.detailItem?.coursework_due_date = format().date(from: date) as NSDate?
            }
            self.detailItem?.coursework_assigned_value = Int64(textview_assignedValue?.text ?? "") ?? 0
            self.detailItem?.coursework_mark = Int64(textview_markAwarded?.text ?? "") ?? 0
            self.detailItem?.coursework_notes = textview_notes?.text
            try self.detailItemContext!.save()
            configureView()
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
    // MARK: Task/Reminder Table Data.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tableView_tasks {
            let sections = self.fetchedResultsController()?.sections?.count ?? 0
            return sections
        } else {
            return self.fetchedResultsRemindersController()?.sections?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView_tasks {
            let sectionInfo = self.fetchedResultsController()!.sections![section]
            let rows = sectionInfo.numberOfObjects
            return rows
        } else {
            return self.fetchedResultsRemindersController()!.sections![section].numberOfObjects
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView_tasks {
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
            let task = self.fetchedResultsController()!.object(at: indexPath)
            self.configureCell(cell, withTask: task)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderTableViewCell
            let reminder = self.fetchedResultsRemindersController()!.object(at: indexPath)
            cell.model = reminder
            cell.configureView()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt: IndexPath) -> Bool {
        //Return false if you do not want the specified item to be editable.
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Coursework? {
        didSet {
            fetchedResultsController()?.fetchRequest.predicate = NSPredicate(format: "coursework == %@", self.detailItem!)
            NSFetchedResultsController<Task>.deleteCache(withName: nil)
            performFetch()
            
            fetchedResultsRemindersController()?.fetchRequest.predicate = NSPredicate(format: "coursework == %@", self.detailItem!)
            NSFetchedResultsController<Reminder>.deleteCache(withName: nil)
            performReminderFetch()
            
            // Update the view.
            self.configureView()
        }
    }

    // MARK: - Fetched results controller for tasks
    func fetchedResultsController() -> NSFetchedResultsController<Task>? {
        if _fetchedResultsController == nil {
            updateFetchedResultsController()
        }
        return _fetchedResultsController
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    func updateFetchedResultsController() {
        if self.detailItem != nil {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
        
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "task_finish_date", ascending: true)
        
            fetchRequest.sortDescriptors = [sortDescriptor]
        
            fetchRequest.predicate = NSPredicate(format: "coursework == %@", self.detailItem!)
        
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            let aFetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            performFetch()
        }
    }
    
    func performFetch() {
        do {
            try _fetchedResultsController?.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Fetched results controller for reminders.
    
    func fetchedResultsRemindersController() -> NSFetchedResultsController<Reminder>? {
        if _fetchedResultsReminderController == nil {
            updateFetchedResultsReminderController()
        }
        return _fetchedResultsReminderController
    }
    
    var _fetchedResultsReminderController: NSFetchedResultsController<Reminder>? = nil
    
    func updateFetchedResultsReminderController() {
        if self.detailItem != nil {
            let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "reminder_date", ascending: true)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchRequest.predicate = NSPredicate(format: "coursework == %@", self.detailItem!)
            
            // Edit the section name key path and cache name if appropriate.
            // nil for section name key path means "no sections".
            let aFetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsReminderController = aFetchedResultsController
            performReminderFetch()
        }
    }
    
    func performReminderFetch() {
        do {
            try _fetchedResultsReminderController?.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == _fetchedResultsController {
            self.tableView_tasks.beginUpdates()
        } else {
            self.tableView_reminders.beginUpdates()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        var tableView: UITableView
        if controller == _fetchedResultsController {
            tableView = self.tableView_tasks
        } else {
            tableView = self.tableView_reminders
        }
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var tableView: UITableView
        if controller == _fetchedResultsController {
            tableView = self.tableView_tasks
        } else {
            tableView = self.tableView_reminders
        }
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let p = indexPath {
                if tableView == tableView_tasks {
                    if let cell = tableView_tasks.cellForRow(at: p) {
                        self.configureCell(cell, withTask: anObject as! Task)
                    }
                }
            }
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        var tableView: UITableView
        if controller == _fetchedResultsController {
            tableView = self.tableView_tasks
        } else {
            tableView = self.tableView_reminders
        }
        tableView.endUpdates()
    }
    
    func configureCell(_ cell: UITableViewCell, withTask task: Task) {
        let c = cell as! TaskTableViewCell
        c.model = task
        c.configureView()
        updateProgress()  // If task progress changed then update details UI progress as well
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverToAddTask" {
            let controller = segue.destination as! AddTaskViewController
            controller.coursework = detailItem
        } else if segue.identifier == "popoverToAddReminder" {
            let controller = segue.destination as! AddCourseworkRemainderViewController
            controller.coursework = detailItem
        }
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     self.tableView.reloadData()
     }
     */
}
