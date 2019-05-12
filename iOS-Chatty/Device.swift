//
//  Device.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import CoreBluetooth

struct Device {
    
    var peripheral : CBPeripheral
    var messages : [String] = []
    var desc: String = "Unknown"
    var user = User()
    
    init(peripheral: CBPeripheral, peripheralDesc: String) {
        self.peripheral = peripheral
        update(desc: desc)
    }
    
    mutating func update(desc: String) {
        let advertisementData = desc.components(separatedBy: "|")
        if (advertisementData.count == 3) {
            self.desc = desc
            user.name = advertisementData[0]
            user.avatarID = Int(advertisementData[1]) ?? 0
            user.colorID = Int(advertisementData[2]) ?? 0
            
        } else {
            self.desc = "Unknown"
            user.name = self.desc
        }
    }
    
    static func <(left: Device, right: Device) -> Bool {
        return left.user.name < right.user.name
    }
}
