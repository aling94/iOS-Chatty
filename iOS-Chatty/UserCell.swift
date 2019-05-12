//
//  UserCell.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/11/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

class UserCell: UICollectionViewCell {
    static let reuseID = "UserCell"
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func set(_ deviceInfo: Device) {
        nameLabel.text = deviceInfo.user.name
    }
}
