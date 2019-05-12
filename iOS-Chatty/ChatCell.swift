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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func set(_ message: Message) {
        sentLabel.isHidden = !message.isSent
        receivedLabel.isHidden = message.isSent
        if message.isSent {
            sentLabel.text = message.body
        } else {
            receivedLabel.text = message.body
        }
    }
}
