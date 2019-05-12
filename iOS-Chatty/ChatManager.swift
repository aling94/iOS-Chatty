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
    
    init(deviceFilter: Set<UUID>) {
        super.init()
        filter = deviceFilter
        chatID = deviceFilter.map({ $0.uuidString }).sorted(by: <).joined(separator: "|")
    }
    
    func messageFRC(delegate: NSFetchedResultsControllerDelegate) -> NSFetchedResultsController<Message> {
        let frc = DataManager.shared.messageFRC(chatID: chatID)
        frc.delegate = delegate
        return frc
    }
    
    func begin() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
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
    
    func updateAdvertisingData()
    {
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let userData = User.current
        let advertisementData = String(format: "%@|%d|%d", userData.name, userData.avatarID, userData.colorID)
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[ChattyBLE.serviceUUID], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    
    func initService() {
        
        let serialService = CBMutableService(type: ChattyBLE.serviceUUID, primary: true)
        let rx = CBMutableCharacteristic(type: ChattyBLE.Characteristics.uuid,
                                         properties: ChattyBLE.Characteristics.properties, value: nil,
                                         permissions: ChattyBLE.Characteristics.permissions)
        serialService.characteristics = [rx]
        
        peripheralManager.add(serialService)
    }
}

extension ChatManager : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == .poweredOn){
            
            self.centralManager?.scanForPeripherals(withServices: [ChattyBLE.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.identifier.description.count > 0
        {
            let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey]
            if advertisementName != nil
            {
                let ad = advertisementName as! String
                let components = ad.components(separatedBy: "|")
                if components.count == 3
                {
                    componentsSet.insert(peripheral)
                }
                print(componentsSet)
                print("----------------")
                
            }
            
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        if componentsSet.contains(peripheral)
        {
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }
}

extension ChatManager : CBPeripheralDelegate {
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if componentsSet.contains(peripheral)
        {
            for service in peripheral.services! {
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            // MARK: - WRITE AND SEND MESSAGE HERE
            let characteristic = characteristic as CBCharacteristic
            if (characteristic.uuid.isEqual(ChattyBLE.Characteristics.uuid)) {
                guard !messageInput.isEmpty else { return }
                let data = messageInput.data(using: .utf8)
                peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                DataManager.shared.createMessage(chatID: chatID, sender: nil, body: messageInput, isSent: true)
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("write here")
    }
}

extension ChatManager : CBPeripheralManagerDelegate {
    
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
                self.peripheralManager.respond(to: request, withResult: .success)
                let messageText = String(data: value, encoding: String.Encoding.utf8)!
                if !messageText.isEmpty {
                    DataManager.shared.createMessage(chatID: chatID, sender: request.central.identifier.uuidString, body: messageText, isSent: false)
                }
            }
            
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        print("this \(peripheral) just received my message")
    }
}
