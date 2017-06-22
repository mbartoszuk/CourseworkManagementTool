//
//  ReminderTableViewCell.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 19/05/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    // Reminder variables.
    @IBOutlet weak var label_reminderDate: UILabel!
    @IBOutlet weak var label_reminderTitle: UILabel!
    
    var model: Reminder?
    
    func configureView() {
        label_reminderDate?.text = format().string(from: model?.reminder_date as! Date)
        label_reminderTitle?.text = model?.reminder_title
    }
    
    // Used to format the date for the due date picker.
    func format() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        return df;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
