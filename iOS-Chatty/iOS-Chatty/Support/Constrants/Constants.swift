//
//  Constants.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import CoreBluetooth
import UIKit

struct ChatService {
    static let uuid = CBUUID(string: "91B5D20C-C99C-4D12-A84F-59C9BFA21EA3")
//    static let serviceUUID = CBUUID(string: "4DF91029-B356-463E-9F48-BAB077BF3EF5")
    static let advertNumComponents = 3
    
    static let service: CBMutableService = {
        let serialService = CBMutableService(type: uuid, primary: true)
        serialService.characteristics = characteristics
        return serialService
    }()
    
    static let characteristics = [chatChannel]
    
    static let chatChannel: CBMutableCharacteristic = {
        return CBMutableCharacteristic(
            type: CBUUID(string: "58E0AE34-909A-4CC2-9779-2475D61B17BD"),
            properties: .write, value: nil,
            permissions: .writeable)
    }()
    
    static var advertisement: String {
        let userData = User.current
        return String(format: "%@|%d|%d", userData.name, userData.avatarID, userData.colorID)
    }
}

struct Constants {
    static let avatarCount = 9
    static let avatarPrefix = "avatar"
    static let maxNameLength = 16
    
}
