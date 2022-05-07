//
//  CategoryTableViewCell.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 30.01.22.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    @IBOutlet var colorView: UIView!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    static let identifier = "CategoryCell"

    public func configureWith(title: String, imageName: String, color: UIColor) {
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        iconView.image = UIImage(systemName: imageName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        colorView.backgroundColor = color
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
