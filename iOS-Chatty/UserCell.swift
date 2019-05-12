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
    
    override var isSelected: Bool {
        didSet {
            if (isSelected) { select() }
            else { deselect() }
        }
    }
    
    func select() {
        contentView.borderWidth = 2.5
        contentView.borderColor = .blue
    }
    
    func deselect() {
        contentView.borderWidth = 0
        contentView.borderColor = .clear
    }
    
    func set(_ deviceInfo: Device) {
        let userInfo = deviceInfo.user
        nameLabel.text = userInfo.name
        imageView.image = UIImage.avatar(id: userInfo.avatarID)
    }
}
