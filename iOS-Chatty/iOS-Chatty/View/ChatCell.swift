//
//  ChatCell.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/11/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    static let reuseID = "ChatCell"

    @IBOutlet weak var sentLabel: PaddedLabel!
    @IBOutlet weak var receivedLabel: PaddedLabel!
    @IBOutlet weak var senderPic: UIImageView!
    @IBOutlet weak var recvPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func set(_ message: Message, avatarID: Int) {
        sentLabel.isHidden = !message.isSent
        senderPic.isHidden = sentLabel.isHidden
        receivedLabel.isHidden = message.isSent
        recvPic.isHidden = receivedLabel.isHidden
        
        let avatar = avatarID > 0 ? UIImage.avatar(id: avatarID) : UIImage.avatar(id: Int(message.avatarID))
        if message.isSent {
            sentLabel.text = message.body
            senderPic.image = avatar
        } else {
            receivedLabel.text = message.body
            recvPic.image = avatar
        }
    }
}
