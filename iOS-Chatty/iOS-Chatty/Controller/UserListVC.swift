//
//  UserListVC.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

class UserListVC: UIViewController {
    
    var timer: Timer!
    
    
    let database = DataManager.shared
    var log: ChatLog!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func test1(_ sender: Any) {
        log = database.createChatLog(recipientID: "TESTID")
        
        _ = database.createMessage(log: log, sender: "SENDER", body: "TEST BODY", isSent: true)
    }
    
    @IBAction func test2(_ sender: Any) {
        let message = (log.messages?.allObjects as! [Message]).first!
        print(message.body)
        print(message.sender)
    }
    
    
}
