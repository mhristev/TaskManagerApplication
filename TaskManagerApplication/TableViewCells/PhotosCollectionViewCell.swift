//
//  PhotosCollectionViewCell.swift
//  TaskManagerApplication
//
//  Created by Martin Hristev on 9.02.22.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    static let identifier = "collectionCell"
    
    @IBOutlet var imageView: UIImageView!
    
    public func configureWith(image: UIImage) {
        self.imageView.image = image
    }
    
    
}
