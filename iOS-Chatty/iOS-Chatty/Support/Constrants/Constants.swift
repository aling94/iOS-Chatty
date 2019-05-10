//
//  Constants.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import CoreBluetooth

struct ChattyBLE {
    static let appUUID = CBUUID(string: "91B5D20C-C99C-4D12-A84F-59C9BFA21EA3")
    static let serviceUUID = CBUUID(string: "58E0AE34-909A-4CC2-9779-2475D61B17BD")
    static let properties: CBCharacteristicProperties = .write
    static let permissions: CBAttributePermissions = .writeable
}
