//
//  AddCourseworkViewController.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 20/04/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import UIKit
import EventKit

class AddCourseworkViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var textfield_moduleName: UITextField!
    @IBOutlet weak var textfield_moduleLevel: UITextField!
    @IBOutlet weak var textfield_courseworkName: UITextField!
    @IBOutlet weak var textfield_courseworkAssignedValue: UITextField!
    @IBOutlet weak var textfield_courseworkDueDate: UITextField!
    @IBOutlet weak var textview_courseworkNotes: UITextView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting the dimensions of the Add Coursework Popover.
        preferredContentSize = CGSize(width: 500, height: 450)
        
        // Create a date picker for the date keyboard.
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(setDueDate(sender:)), for: .valueChanged)
        textfield_courseworkDueDate.inputView = datePicker
        
        /*
        // Attempting to create a custom course level picker. Uses the ArrayPicker class.
        let levels = ArrayPicker()
        levels.items = ["4", "5", "6", "7"]
        levels.view = textfield_moduleLevel
        let levelPicker = UIPickerView()
        levelPicker.delegate = levels
        levelPicker.dataSource = levels
        textfield_moduleLevel.inputView = levelPicker
         */
    }
    
    // Sets the text in the due date field, to what is picked in the date picker.
    func setDueDate(sender: UIDatePicker) {
        textfield_courseworkDueDate.text = format().string(from: sender.date)
    }
    
    // Button on the popover, which saves the new coursework details.
    @IBAction func button_saveCoursework(_ sender: Any) {
        
        // Validating that the coursework name and due date are filled in before saving the coursework details.
        if !(self.textfield_courseworkName.text ?? "").isEmpty && !(self.textfield_courseworkDueDate.text ?? "").isEmpty {
        
            let newCoursework = Coursework(context: context)
            newCoursework.module_name = self.textfield_moduleName.text
            newCoursework.module_level = Int64(self.textfield_moduleLevel.text!)!
            newCoursework.coursework_create_date = Date.init(timeIntervalSinceNow: 0) as NSDate?
            newCoursework.coursework_name = self.textfield_courseworkName.text
            newCoursework.coursework_assigned_value = Int64(self.textfield_courseworkAssignedValue.text!)!
            newCoursework.coursework_due_date = format().date(from: self.textfield_courseworkDueDate.text!) as NSDate?
            newCoursework.coursework_notes = self.textview_courseworkNotes.text
        
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.dismiss(animated: true)
            
            // Saving the coursework due date in the Calendar.
            // Adapted code from:
            // http://stackoverflow.com/questions/28379603/how-to-add-an-event-in-the-device-calendar-using-swift
            let eventStore : EKEventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event) { (granted : Bool, error : Error?) in
                if (granted) && (error == nil) {
                    print ("granted \(granted)")
                    print ("error \(error)")
                    
                    let event:EKEvent = EKEvent(eventStore: eventStore)
                    event.title = newCoursework.coursework_name!
                    event.startDate = (newCoursework.coursework_due_date! as Date).addingTimeInterval(-1 * 60 * 60)
                    event.endDate = newCoursework.coursework_due_date! as Date
                    event.notes = "This coursework is due today!"
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError {
                        print("failed to save event with error : \(error)")
                    }
                    print ("Saved event")
                }
                else {
                    print("failed to save event with error : \(error) or access not granted")
                }
            }
            
        } else {
            let alert = UIAlertController(title: "Missing coursework name and / or due date",message: "Please make sure these two values are entered correctly.",preferredStyle: .alert)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Popup to make sure all the required data is entered in the popover.
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        if self.textfield_courseworkName.text!.isEmpty || self.textfield_courseworkDueDate.text!.isEmpty {
            return true
        } else {
            let alert = UIAlertController(title: "Would you like to save the new coursework?",message: "",preferredStyle: .alert)
            let DiscardAction = UIAlertAction(title: "Discard", style: .default, handler: {(UIAlertAction) -> Void in self.dismiss(animated: true, completion: nil)})
            alert.addAction(DiscardAction)
            let SaveAction = UIAlertAction(title: "Save", style: .default, handler: {(action: UIAlertAction) -> Void in self.button_saveCoursework(action)})
            alert.addAction(SaveAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

/*
// Attempted to create a custom keyboard for special cases, such as level picking,
// where the user should only be allowed to enter specific values.
class ArrayPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var items: [String] = ["4", "5", "6", "7"]
    var view: UITextField?
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.view?.text = items[row]
    }
}
*/
