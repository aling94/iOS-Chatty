//
//  ImageCell.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/12/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    static let reuseID = "ImageCell"
    @IBOutlet weak var imageView: UIImageView!
    
    func setAvatarImage(id: Int) {
        imageView.image = UIImage.avatar(id: id)
    }
}
