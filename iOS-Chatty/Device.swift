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
    var name : String
    var messages : [String] = []
    
    init(peripheral: CBPeripheral, name: String) {
        self.peripheral = peripheral
        self.name = name
    }
    
    static func <(left: Device, right: Device) -> Bool {
        return left.name < right.name
    }
}
