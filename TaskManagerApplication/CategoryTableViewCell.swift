//
//  CategoryTableViewCell.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 30.01.22.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    static func nib() -> UINib {
        return UINib(nibName: "CategoryCell", bundle: nil)
    }

    public func configure() {
        return
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
