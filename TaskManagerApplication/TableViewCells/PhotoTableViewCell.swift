//
//  PhotoTableViewCell.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 9.02.22.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    static let identifier = "photoCell"
    
    @IBOutlet var imgView: UIImageView!
    
    public func configureWith(image: UIImage) {
        self.imgView.image = image
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
