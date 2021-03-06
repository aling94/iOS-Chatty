//
//  Device.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Device {
    
    var peripheral : CBPeripheral
    var messages : [String] = []
    var desc: String = "Unknown"
    var user = User()
    var deviceID = ""
    
    init(peripheral: CBPeripheral, peripheralDesc: String) {
        self.peripheral = peripheral
        update(desc: peripheralDesc)
    }
    
    mutating func update(desc: String) {
        let advertisementData = desc.components(separatedBy: "|")
        if (advertisementData.count == ChatService.advertNumComponents) {
            self.desc = desc
            user.name = advertisementData[0]
            user.avatarID = Int(advertisementData[1]) ?? 0
            user.colorID = Int(advertisementData[2]) ?? 0
        }
    }
    
    var uuid: UUID {
        return peripheral.identifier
    }
    
    static func <(left: Device, right: Device) -> Bool {
        return left.user.name < right.user.name
    }
}
