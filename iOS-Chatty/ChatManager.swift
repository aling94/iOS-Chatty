//
//  ChatManager.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/11/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import CoreBluetooth
import CoreData

protocol ChatManagerDelegate: class {
    
}

class ChatManager: NSObject {
    
    var chatID: String!
    var filter: Set<UUID>!
    private var peripheralManager: CBPeripheralManager!
    private var centralManager: CBCentralManager!
    private var visibleDevices: [Device] = []
    private var cachedDevices: [Device] = []
    private var componentsSet: Set<CBPeripheral> = []
    
    weak var delegate: ChatManagerDelegate?
    
    var messageInput = ""
    
    init(chatID: String, deviceFilter: Set<UUID>) {
        super.init()
        self.chatID = chatID
        filter = deviceFilter
        peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.global())
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
    }
    
    func sendMessage(text: String) {
        messageInput = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageInput.isEmpty && !componentsSet.isEmpty else { return }
        for item in componentsSet
        {
            centralManager?.connect(item, options: nil)
        }
        
        _ = DataManager.shared.createMessage(chatID: chatID, sender: nil, body: messageInput, isSent: true)
    }
    
    func updateAdvertisingData() {
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let user = User.current
        let advertisementData = String(format: "%@|%d|%d", user.name, user.avatarID, user.colorID)
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[ChattyBLE.serviceUUID], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    
    func initService() {
        let serialService = CBMutableService(type: ChattyBLE.serviceUUID, primary: true)
        serialService.characteristics = [CBMutableCharacteristic(type: ChattyBLE.Characteristics.uuid,
                                                                 properties: ChattyBLE.Characteristics.properties,
                                                                 value: nil, permissions: ChattyBLE.Characteristics.permissions)]
        peripheralManager.add(serialService)
    }
}

extension ChatManager: CBPeripheralDelegate {
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if componentsSet.contains(peripheral) {
            for service in peripheral.services! {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        
        for characteristic in service.characteristics! {
            // MARK: - WRITE AND SEND MESSAGE HERE
            let characteristic = characteristic as CBCharacteristic
            if (characteristic.uuid.isEqual(ChattyBLE.Characteristics.uuid)) {
                guard messageInput.isEmpty else { return }
                let data = messageInput.data(using: .utf8)
                peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("write here")
    }
}

extension ChatManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn){
            initService()
            updateAdvertisingData()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests
        {
            if let value = request.value {
                // MARK: - RECEIVING MESSAGE
                
                guard let messageText = String(data: value, encoding: String.Encoding.utf8),
                    !messageText.isEmpty else { return }
                let sender = request.central.identifier.uuidString
                peripheral.respond(to: request, withResult: .success)
                _ = DataManager.shared.createMessage(chatID: chatID, sender: sender, body: messageText, isSent: false)
            }
            
        }
    }
}

extension ChatManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == .poweredOn){
            central.scanForPeripherals(withServices: [ChattyBLE.serviceUUID],
                                       options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard filter.contains(peripheral.identifier) else { return }
        // Constantly running to check for new peripherals
        if peripheral.identifier.description.count > 0 {
            let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey]
            if advertisementName != nil {
                let ad = advertisementName as! String
                let components = ad.components(separatedBy: "|")
                if components.count == 3 {
                    componentsSet.insert(peripheral)
                }
                print(componentsSet, "----------------\n")
            }
            
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Gets called for several existing peripherals
        if componentsSet.contains(peripheral) {
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }
    
}
