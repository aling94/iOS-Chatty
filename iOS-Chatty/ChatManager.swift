//
//  ChatManager.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/11/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

protocol ChatManagerDelegate: class {
    
}

class ChatManager: NSObject {
    
    var chatID: String!
    var filter: Set<UUID>!
    var chatName: String!
    private var peripheralManager: CBPeripheralManager!
    private var centralManager: CBCentralManager!
    private var peripheralSet: Set<CBPeripheral> = []
    private var deviceMap: [String : Device] = [:]
    private var firstWrite = false
    
    weak var delegate: ChatManagerDelegate?
    
    var messageInput = ""
    
    init(filter: [Device], devices: [Device]) {
        super.init()
        self.filter = Set<UUID>(filter.map({$0.uuid}))
        if filter.isEmpty {
            chatName = "All"
            chatID = "All"
        } else {
            chatName = filter.map({ $0.user.name.isEmpty ? "Unknown" : $0.user.name}).joined(separator: " | ")
            chatID = filter.map({ $0.uuid.uuidString }).sorted(by: <).joined(separator: ";")
        }
        
        devices.forEach({self.deviceMap[$0.uuid.uuidString] = $0})
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
        guard !messageInput.isEmpty && !peripheralSet.isEmpty else { return }
        firstWrite = false
        for item in peripheralSet {
            centralManager?.connect(item, options: nil)
        }
    }
    
    func updateAdvertisingData() {
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let advertisementData = ChattyBLE.advertisement
        
        let advertisement: [String : Any] = [
            CBAdvertisementDataServiceUUIDsKey:[ChattyBLE.serviceUUID],
            CBAdvertisementDataLocalNameKey: advertisementData
        ]
        
        peripheralManager.startAdvertising(advertisement)
    }
    
    
    func initService() {
        
        let serialService = CBMutableService(type: ChattyBLE.serviceUUID, primary: true)
        let rx = CBMutableCharacteristic(type: ChattyBLE.Characteristics.uuid,
                                         properties: ChattyBLE.Characteristics.properties, value: nil,
                                         permissions: ChattyBLE.Characteristics.permissions)
        serialService.characteristics = [rx]
        
        peripheralManager.add(serialService)
    }
    
    func shouldAcceptPeripheral(advertisement: [String : Any], peripheral: CBPeripheral) -> Bool {
        guard let uuids = advertisement[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID],
            let serviceUUID = uuids.first,
            serviceUUID == ChattyBLE.serviceUUID else { return false }
        return filter.isEmpty || filter.contains(peripheral.identifier)
    }
    
    func avatarForSender(senderID: String) -> Int {
        return deviceMap[senderID]?.user.avatarID ?? 0
    }
}

//  MARK: - CBCentralManagerDelegate
extension ChatManager : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == .poweredOn) {
            
            central.scanForPeripherals(withServices: [ChattyBLE.serviceUUID],
                                       options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard shouldAcceptPeripheral(advertisement: advertisementData, peripheral: peripheral),
            peripheral.identifier.description.count > 0,
            let adName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        
        let components = adName.components(separatedBy: "|")
        if components.count == ChattyBLE.advertNumComponents {
            peripheralSet.insert(peripheral)
            if deviceMap[peripheral.identifier.uuidString] != nil {
                deviceMap[peripheral.identifier.uuidString]!.user.name = components[0]
            }
        }
        print(peripheralSet, "----------------\n")
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheralSet.contains(peripheral) {
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        peripheralSet.remove(peripheral)
    }
}

//  MARK: - CBPeripheralDelegate
extension ChatManager : CBPeripheralDelegate {
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheralSet.contains(peripheral) {
            for service in peripheral.services! {
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let characteristic = characteristic as CBCharacteristic
            if (characteristic.uuid.isEqual(ChattyBLE.Characteristics.uuid)) {
                guard !messageInput.isEmpty else { return }
                let data = messageInput.data(using: .utf8)
                peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard !messageInput.isEmpty && !firstWrite else { return }
        DataManager.shared.createMessage(chatID: chatID, sender: nil, body: messageInput, isSent: true)
        firstWrite = true
    }
}

//  MARK: - CBPeripheralManagerDelegate
extension ChatManager : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn) {
            
            initService()
            updateAdvertisingData()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests{
            if let value = request.value {
                peripheral.respond(to: request, withResult: .success)
                var messageText = String(data: value, encoding: String.Encoding.utf8)!
                if !messageText.isEmpty {
                    let senderID = request.central.identifier.uuidString
                    if filter.count != 1 {
                        
                        let senderName = deviceMap[senderID]?.user.name ?? "Unknown"
                        messageText = "[\(senderName)] : \(messageText)"
                    }
                    DataManager.shared.createMessage(chatID: chatID, sender:senderID , body: messageText, isSent: false)
                }
            }
            
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        print("this \(peripheral) just received my message")
    }
}
