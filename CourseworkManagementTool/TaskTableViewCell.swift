//
//  TaskTableViewCell.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 07/05/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate {

    // Task Table variables that can be displayed and edited.
    @IBOutlet weak var textField_taskName: UITextField!
    @IBOutlet weak var label_daysLeft: UILabel!
    @IBOutlet weak var label_progress: UILabel!
    @IBOutlet weak var taskProgressGraphic: TaskProgressGraphic!
    @IBOutlet weak var textField_startTime: UITextField!
    @IBOutlet weak var textField_desiredFinishTime: UITextField!
    @IBOutlet weak var textView_notes: UITextView!
    
    var model: Task?
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func configureView() {
        //Task name.
        textField_taskName?.text = model?.task_name
        
        // Task finish date.
        if let finish = model?.task_finish_date {
            textField_desiredFinishTime?.text = format().string(from: finish as Date)
            
            // Compute how many days are left:
            var daysLeft = Int(finish.timeIntervalSinceNow / (24 * 60 * 60))
            if daysLeft < 0 {
                daysLeft = 0
            }
            label_daysLeft?.text = "\(daysLeft)"
        }
        
        // Task progress.
        taskProgressGraphic?.ratio = model?.progress ?? 0.0
        
        // Task start date.
        if let start = model?.task_start_date {
            textField_startTime?.text = format().string(from: start as Date)
        }
        
        //Task notes.
        textView_notes?.text = model?.task_notes ?? ""
        
        textField_taskName.delegate = self
        textField_startTime.delegate = self
        textField_desiredFinishTime.delegate = self
        textView_notes.delegate = self
        
        // Create a date picker variable for the start task date keyboard.
        let startTaskDatePicker = UIDatePicker()
        startTaskDatePicker.addTarget(self, action: #selector(setTaskStartDate(sender:)), for: .valueChanged)
        textField_startTime.inputView = startTaskDatePicker
        
        // Create a date picker variable for the desired end task date keyboard.
        let endTaskDatePicker = UIDatePicker()
        endTaskDatePicker.addTarget(self, action: #selector(setTaskEndDate(sender:)), for: .valueChanged)
        textField_desiredFinishTime.inputView = endTaskDatePicker
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        taskProgressGraphic?.ratioChanged = {(ignored: Float) in }
        taskProgressGraphic?.ratio = 0.0  // TEST
        taskProgressGraphic?.ratioChanged = setProgress
    }
    
    // Update the model whenever the data is changed.
    func textViewDidChange(_ textView: UITextView) {
        updateModel()
    }
    
    // Invoked whenever text has changed in any of the details text views.
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateModel()
    }
    
    func updateModel() {
        model?.task_name = textField_taskName?.text
        model?.progress = taskProgressGraphic.ratio
        if let date = textField_startTime?.text {
            model?.task_start_date = format().date(from: date) as NSDate?
        }
        if let date = textField_desiredFinishTime?.text {
            model?.task_finish_date = format().date(from: date) as NSDate?
        }
        model?.task_notes = textView_notes?.text
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
    func setProgress(value: Float) {
        let percent = Int((value * 100).rounded())
        label_progress?.text = "Progress: \(percent)%"
        if value != model?.progress {
            updateModel()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Sets the text in the task start date field, to what is picked in the date picker.
    func setTaskStartDate(sender: UIDatePicker) {
        textField_startTime.text = format().string(from: sender.date)
    }
    
    // Sets the text in the task end date field, to what is picked in the date picker.
    func setTaskEndDate(sender: UIDatePicker) {
        textField_desiredFinishTime.text = format().string(from: sender.date)
    }
    
    // Used to format the date for any date picker.
    func format() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        return df;
    }
    
    // The task delete button.
    @IBAction func button_deleteTask(_ sender: UIButton) {
        managedObjectContext.delete(model!)
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
}
