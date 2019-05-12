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
    
    var frc: NSFetchedResultsController<Message>!
    var cm: ChatManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frc = cm.messageFRC(delegate: self)
        try? frc.performFetch()
        cm.begin()
    }


    @IBAction func testSendMessage(_ sender: Any) {
        cm.sendMessage(text: "Hello world \(frc.fetchedObjects!.count)")
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
        let lastRow = (frc.fetchedObjects?.count)! - 1
        if lastRow > 0 {
            table?.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: true)
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        switch type {
        case .insert:
            guard let newIdp = newIndexPath else { return }
            let message = frc.object(at: newIdp)
            let dir : UITableView.RowAnimation = message.isSent ? .right : .left
            table.insertRows(at: [newIdp], with: dir)
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
