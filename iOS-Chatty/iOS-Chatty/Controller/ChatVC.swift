//
//  ChatVC.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class ChatVC: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    var deviceUUID : UUID?
    var deviceAttributes : String = ""
    var selectedPeripheral : CBPeripheral?
    var centralManager: CBCentralManager?
    var peripheralManager = CBPeripheralManager()
    
    var componentsSet: Set<CBPeripheral> = []
    
    var frc: NSFetchedResultsController<Message>!
    var cm: ChatManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frc = cm.messageFRC(delegate: self)
        try? frc.performFetch()
        cm.begin()
//        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
//        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }


    @IBAction func testSendMessage(_ sender: Any) {
        cm.sendMessage(text: "Hello world")
//        for item in componentsSet
//        {
//            centralManager?.connect(item, options: nil)
//        }
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
        let rx = CBMutableCharacteristic(type: ChattyBLE.Characteristics.uuid, properties: ChattyBLE.Characteristics.properties, value: nil, permissions: ChattyBLE.Characteristics.permissions)
        serialService.characteristics = [rx]
        
        peripheralManager.add(serialService)
    }
}

extension ChatVC : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (central.state == .poweredOn){
            
            self.centralManager?.scanForPeripherals(withServices: [ChattyBLE.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Constantly running to check for new peripherals
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
        
        //        if (peripheral.identifier == deviceUUID) {
        //
        //           // selectedPeripheral = peripheral
        //
        //        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        // Gets called for several existing peripherals
        if componentsSet.contains(peripheral)
        {
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }
}

extension ChatVC : CBPeripheralDelegate {
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if componentsSet.contains(peripheral)
        {
            for service in peripheral.services! {
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        // Note: For each peripheral ... write message
        for characteristic in service.characteristics! {
            // MARK: - WRITE AND SEND MESSAGE HERE
            let characteristic = characteristic as CBCharacteristic
            if (characteristic.uuid.isEqual(ChattyBLE.Characteristics.uuid)) {
                let messageText = "Hello world"
                    let data = messageText.data(using: .utf8)
                    // Write values to a peripheral, can send image too
                    peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
//                    appendMessageToChat(message: Message(text: messageText, isSent: true))
                    // MARK: - SHOULD CLEAR FIELD ON SEND
//                    messageTextField.text = ""
                DataManager.shared.createMessage(chatID: cm.chatID, sender: nil, body: messageText, isSent: true)
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("write here")
    }
}

extension ChatVC : CBPeripheralManagerDelegate {
    
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
                // Check if has image too?
                self.peripheralManager.respond(to: request, withResult: .success)
                let messageText = String(data: value, encoding: String.Encoding.utf8)!
                if !messageText.isEmpty {
//                    appendMessageToChat(message: Message(text: messageText, isSent: false))
                    DataManager.shared.createMessage(chatID: cm.chatID, sender: request.central.identifier.uuidString, body: messageText, isSent: false)
                }
            }
            
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        print("this \(peripheral) just received my message")
    }
}

extension ChatVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.reuseID) as? ChatCell else {
            return UITableViewCell()
        }
        cell.set(frc.object(at: indexPath))
        return cell
    }
    
    
}

extension ChatVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        switch type {
        case .insert:
            guard let newIdp = newIndexPath else { return }
            table.insertRows(at: [newIdp], with: .automatic)
        case .move:
            guard let idp = indexPath, let newIdp = newIndexPath else { return }
            table.deleteRows(at: [idp], with: .automatic)
            table.insertRows(at: [newIdp], with: .automatic)
        case .update:
            guard let idp = indexPath, let cell = table.cellForRow(at: idp) as? ChatCell else { return }
            cell.set(frc.object(at: idp))
        case .delete:
            guard let idp = indexPath else { return }
            table.deleteRows(at: [idp], with: .automatic)
        @unknown default: break
        }
    }
}
