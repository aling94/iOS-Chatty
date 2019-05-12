//
//  User.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import Foundation

fileprivate let currentUserKey = "currentUser"

class User {
    
    var name = "Unknown"
    var colorID = 0
    var avatarID = 0
    
    
    static let current: User = {
        let user = User()
        if let dictionary = UserDefaults.standard.dictionary(forKey: currentUserKey) {
            
            user.name = dictionary["name"] as? String ?? "Unknown"
            user.avatarID = dictionary["avatarId"] as? Int ?? 0
            user.colorID = dictionary["colorId"] as? Int ?? 0
        }
        return user
    }()

    func save() {
        let dictionary : Dictionary<String, Any> = ["name": name, "avatarId": avatarID, "colorId": colorID]
        UserDefaults.standard.set(dictionary, forKey: currentUserKey)
    }
    
    
    
}
