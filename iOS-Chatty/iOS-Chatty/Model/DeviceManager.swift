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
    func deviceManagerDidUpdateDeviceDesc(at index: Int)
    func deviceManagerDidReload()
}

final class DeviceManager: NSObject {
    
    private var peripheralManager: CBPeripheralManager!
    private var centralManager: CBCentralManager!
    var visibleDevices: [Device] = []
    private var cachedDevices: [Device] = []
    private var cachedPeripheralNames: [String : String] = [:]
    weak var delegate: DeviceManagerDelegate?
    
    var timer: Timer!
    
    init(delegate: DeviceManagerDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    var deviceCount: Int { return visibleDevices.count }
    
    func device(at index: Int) -> Device {
        return visibleDevices[index]
    }
    
    func begin() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        startReloads()
    }
    
    func startReloads() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self,
                                     selector: #selector(clearPeripherals), userInfo: nil, repeats: true)
    }
    
    func stopReloads() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func clearPeripherals() {
        visibleDevices = cachedDevices
        cachedDevices.removeAll()
        delegate?.deviceManagerDidReload()
    }
    
    func updateAdvertisingData() {
        
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }

        let advertisementData = ChatService.advertisement
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[ChatService.uuid], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    private func addOrUpdatePeripheralList(device: Device, list: inout [Device]) {
        
        if !list.contains(where: { $0.peripheral.identifier == device.peripheral.identifier }) {
            
            list.append(device)
            delegate?.deviceManager(didAddNewPeripheral: device)
        }
        else if list.contains(where: { $0.peripheral.identifier == device.peripheral.identifier
            && $0.desc == "Unknown"}) && device.desc != "Unknown" {
            
            for index in 0..<list.count {
                if (list[index].peripheral.identifier == device.peripheral.identifier) {
                    list[index].update(desc: device.desc)
                    delegate?.deviceManagerDidUpdateDeviceDesc(at: index)
                    break
                }
            }
            
        }
    }
}

//  MARK: - CBPeripheralManagerDelegate
extension DeviceManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            updateAdvertisingData()
        }
    }
}

//  MARK: - CBCentralManagerDelegate
extension DeviceManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [ChatService.uuid],
                                       options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var peripheralInfo = cachedPeripheralNames[peripheral.identifier.description] ?? "Unknown"
        if let advertisementname = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralInfo = advertisementname
            cachedPeripheralNames[peripheral.identifier.description] = peripheralInfo
        }
        let device = Device(peripheral: peripheral, peripheralDesc: peripheralInfo)
        
        self.addOrUpdatePeripheralList(device: device, list: &visibleDevices)
        self.addOrUpdatePeripheralList(device: device, list: &cachedDevices)
    }
}
