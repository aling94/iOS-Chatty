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
        sentLabel.isHidden = true
        receivedLabel.isHidden = true
    }
    
    func set(_ message: Message) {
        if message.isSent {
            sentLabel.isHidden = false
            sentLabel.text = message.body
        } else {
            receivedLabel.isHidden = false
            receivedLabel.text = message.body
        }
    }
}
