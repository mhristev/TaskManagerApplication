//
//  ReminderTableViewCell.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 4.02.22.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet var checkBox: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    static let identifier = "ReminderCell"
    
    public func configureWith(title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
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
