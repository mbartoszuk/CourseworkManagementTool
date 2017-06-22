//
//  AddTaskViewController.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 06/05/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // Task data variables.
    @IBOutlet weak var textfield_taskName: UITextField!
    @IBOutlet weak var textfield_startTime: UITextField!
    @IBOutlet weak var textfield_finishTime: UITextField!
    @IBOutlet weak var textfield_taskNotes: UITextView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var coursework: Coursework?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Setting the dimensions of the Add Task Popover.
        preferredContentSize = CGSize(width: 500, height: 388)
        
        // Create a date picker variable for the start date keyboard.
        let startDatePicker = UIDatePicker()
        startDatePicker.addTarget(self, action: #selector(setStartDate(sender:)), for: .valueChanged)
        textfield_startTime.inputView = startDatePicker
        
        // Create a date picker variable for the finish date keyboard.
        let finishDatePicker = UIDatePicker()
        finishDatePicker.addTarget(self, action: #selector(setFinishDate(sender:)), for: .valueChanged)
        textfield_finishTime.inputView = finishDatePicker
    }
    
    // Sets the text in the start date field, to what is picked in the date picker.
    func setStartDate(sender: UIDatePicker) {
        textfield_startTime.text = format().string(from: sender.date)
    }
    
    // Sets the text in the finish date field, to what is picked in the date picker.
    func setFinishDate(sender: UIDatePicker) {
        textfield_finishTime.text = format().string(from: sender.date)
    }
    
    // Button that saves the task with the entered data.
    @IBAction func button_saveTask(_ sender: Any) {
        
        // Validating that the task name and start and finish dates are filled in before saving the task details.
        if !(self.textfield_taskName.text ?? "").isEmpty && !(self.textfield_startTime.text ?? "").isEmpty && !(self.textfield_finishTime.text ?? "").isEmpty {
        
            let newTask = Task(context: context)
            newTask.coursework = coursework
            newTask.task_name = self.textfield_taskName.text
            newTask.task_start_date = format().date(from: self.textfield_startTime.text!) as NSDate?
            newTask.task_finish_date = format().date(from: self.textfield_finishTime.text!) as NSDate?
            newTask.task_notes = self.textfield_taskNotes.text
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "Missing task name, start and / or finish dates.",message: "Please make sure these values are entered correctly.",preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Used to format the date for the due date picker.
    func format() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df;
    }
}
