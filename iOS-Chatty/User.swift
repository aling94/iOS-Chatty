//
//  User.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import Foundation

class User {
    
    private let currentUserKey = "currentUser"
    
    static let current = User()
    
    init() {
        if let dictionary = UserDefaults.standard.dictionary(forKey: currentUserKey) {
            
            name = dictionary["name"] as? String ?? ""
            avatarID = dictionary["avatarId"] as? Int ?? 0
            colorID = dictionary["colorId"] as? Int ?? 0
        }
    }
    
    var name = ""
    var colorID = 0
    var avatarID = 0
    
    
}
