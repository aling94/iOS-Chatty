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
    
    struct Characteristics {
        static let uuid = CBUUID(string: "58E0AE34-909A-4CC2-9779-2475D61B17BD")
        static let properties: CBCharacteristicProperties = .write
        static let permissions: CBAttributePermissions = .writeable
    }
    
    static let bgColors: [UIColor] = [
        UIColor(red: 0/255, green: 102/255, blue:155/255, alpha: 1.0),
        UIColor(red: 102/255, green: 204/255, blue:255/255, alpha: 1.0),
        UIColor(red: 0/255, green: 153/255, blue:51/255, alpha: 1.0),
        UIColor(red: 255/255, green: 153/255, blue:0/255, alpha: 1.0),
        UIColor(red: 255/255, green: 51/255, blue:0/255, alpha: 1.0),
        UIColor(red: 255/255, green: 51/255, blue:204/255, alpha: 1.0),
        UIColor(red: 255/255, green: 255/255, blue:0/255, alpha: 1.0),
        UIColor(red: 153/255, green: 51/255, blue:255/255, alpha: 1.0),
        UIColor(red: 153/255, green: 102/255, blue:0/255, alpha: 1.0)
    ]
}
