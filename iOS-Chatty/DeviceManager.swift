//
//  BLEManager.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/11/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import CoreBluetooth

protocol DeviceManagerDelegate: class {
    func deviceManager(didAddNewPeripheral: Device)
}

final class DeviceManager: NSObject {
    
    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    var visibleDevices: [Device] = []
    var cachedDevices: [Device] = []
    var cachedPeripheralNames: [String : String] = [:]
    weak var delegate: DeviceManagerDelegate?
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.global())
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
    }
    
    private func updateAdvertisingData() {
        
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let user = User.current
        let advertisementData = String(format: "%@|%d|%d", user.name, user.avatarID, user.colorID)
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[ChattyBLE.serviceUUID], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    private func addOrUpdatePeripheralList(device: Device, list: inout [Device]) {
        
        if !list.contains(where: { $0.peripheral.identifier == device.peripheral.identifier }) {
            list.append(device)
            delegate?.deviceManager(didAddNewPeripheral: device)
        }
        else if list.contains(where: { $0.peripheral.identifier == device.peripheral.identifier
            && $0.name == "unknown"}) && device.name != "unknown" {
            
            for index in 0..<list.count {
                if (list[index].peripheral.identifier == device.peripheral.identifier) {
                    list[index].name = device.name
                    break
                }
            }
            
        }
    }
    
    
}

extension DeviceManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            updateAdvertisingData()
        }
    }
    
    
}

extension DeviceManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [ChattyBLE.serviceUUID],
                                       options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var peripheralName = cachedPeripheralNames[peripheral.identifier.description] ?? "Unknown"
        if let advertisementname = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = advertisementname
            cachedPeripheralNames[peripheral.identifier.description] = peripheralName
        }
        let device = Device(peripheral: peripheral, name: peripheralName)
        
        self.addOrUpdatePeripheralList(device: device, list: &visibleDevices)
        self.addOrUpdatePeripheralList(device: device, list: &cachedDevices)
    }
}
