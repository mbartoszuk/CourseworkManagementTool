//
//  AddCourseworkRemainderViewControllerTableViewCell.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 18/05/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import UIKit

class AddCourseworkRemainderViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    //Reminder variables.
    @IBOutlet weak var textview_reminderDate: UITextField!
    @IBOutlet weak var textview_reminderTitle: UITextField!
    
    var coursework: Coursework?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the dimensions of the Add Reminder Popover.
        preferredContentSize = CGSize(width: 500, height: 190)
        
        // Create a date picker variable for the reminder date keyboard.
        let reminderDatePicker = UIDatePicker()
        reminderDatePicker.addTarget(self, action: #selector(setReminderDate(sender:)), for: .valueChanged)
        textview_reminderDate.inputView = reminderDatePicker
    }
    
    // Sets the text in the reminder date field, to what is picked in the date picker.
    func setReminderDate(sender: UIDatePicker) {
        textview_reminderDate.text = format().string(from: sender.date)
    }
    
    // Button to save the new reminder data.
    @IBAction func button_saveReminder(_ sender: Any) {
        // Validating that the reminder title and due date are filled in before saving the coursework details.
        if !(self.textview_reminderTitle.text ?? "").isEmpty && !(self.textview_reminderDate.text ?? "").isEmpty {
            
            let newReminder = Reminder(context: context)
            newReminder.coursework = self.coursework
            newReminder.reminder_title = self.textview_reminderTitle.text
            newReminder.reminder_date = format().date(from: self.textview_reminderDate.text!)! as NSDate
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.dismiss(animated: true)
            
        } else {
            let alert = UIAlertController(title: "Missing reminder title and / or date",message: "Please make sure these two values are entered correctly.",preferredStyle: .alert)
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
