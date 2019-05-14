//
//  Constants.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import CoreBluetooth
import UIKit

struct ChattyBLE {
    static let serviceUUID = CBUUID(string: "91B5D20C-C99C-4D12-A84F-59C9BFA21EA3")
//    static let serviceUUID = CBUUID(string: "4DF91029-B356-463E-9F48-BAB077BF3EF5")
    static let advertNumComponents = 3
    
    struct Characteristics {
        static let uuid = CBUUID(string: "58E0AE34-909A-4CC2-9779-2475D61B17BD")
//        static let uuid = CBUUID(string: "3B66D024-2336-4F22-A980-8095F4898C42")
        static let properties: CBCharacteristicProperties = .write
        static let permissions: CBAttributePermissions = .writeable
    }
    
    static var advertisement: String {
        let userData = User.current
        return String(format: "%@|%d|%d", userData.name, userData.avatarID, userData.colorID)
    }
    
    static let currentDeviceID: String = {
        let key = "currentDeviceID"
        if let deviceID = UserDefaults.standard.string(forKey: key) {
            return deviceID
        }
        guard let uuid = UIDevice.current.identifierForVendor else { return "" }
        let deviceID = uuid.uuidString.components(separatedBy: "-")[0]
        UserDefaults.standard.setValue(deviceID, forKey: key)
        return deviceID
    }()
}

struct Constants {
    static let avatarCount = 9
    static let avatarPrefix = "avatar"
    static let maxNameLength = 16
    
}
