//
//  User.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import Foundation

class User {
    
    var name = ""
    var colorID = 0
    var avatarID = 0
    
    private static let currentUserKey = "currentUser"
    
    static let current: User = {
        let user = User()
        if let dictionary = UserDefaults.standard.dictionary(forKey: currentUserKey) {
            
            user.name = dictionary["name"] as? String ?? ""
            user.avatarID = dictionary["avatarId"] as? Int ?? 0
            user.colorID = dictionary["colorId"] as? Int ?? 0
        }
        return user
    }()

    
    
    
    
}
