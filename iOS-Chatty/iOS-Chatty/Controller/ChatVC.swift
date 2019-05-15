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
import ViewAnimator

class ChatVC: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var textFieldBottom: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    
    var frc: NSFetchedResultsController<Message>!
    var cm: ChatManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = cm.chatName
        cm.begin()
        
        frc = cm.messageFRC(delegate: self)
        try? frc.performFetch()
        toggleSendBtn(enabled: false)
        hideKeyboardOnScreenTap()
        observeKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.reloadData()
        let lastRow = table.numberOfRows(inSection: 0) - 1
        DispatchQueue.main.async {
            if lastRow > 0 {
                self.table?.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: false)
            }
            let anim = AnimationType.from(direction: .bottom, offset: 30.0)
            UIView.animate(views: self.table.visibleCells,
                           animations: [anim],
                           duration: 0.8)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    func toggleSendBtn(enabled: Bool) {
        sendBtn.isEnabled = enabled
        sendBtn.setTitleColor(enabled ? .lightBlue : .gray, for: .normal)
    }

    @IBAction func sendTapped(_ sender: Any) {
        view.endEditing(true)
        cm.sendMessage(text: inputField.text!)
        inputField.text = ""
        toggleSendBtn(enabled: false)
    }
}

//  MARK: - Observers
extension ChatVC {
    func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification : Notification) {
        if let userInfo = notification.userInfo {
            if let keySize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                textFieldBottom.constant = keySize.height
                UIView.animate(withDuration: 1.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification : Notification) {
        if let userInfo = notification.userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                textFieldBottom.constant = 0
                UIView.animate(withDuration: 1.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

//  MARK: - UITextFieldDelegate
extension ChatVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! + string
        if textField.text!.count == 1 && string.isEmpty { newText = "" }
        toggleSendBtn(enabled: !newText.isEmpty)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//  MARK: - UITableViewDataSource
extension ChatVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.reuseID) as? ChatCell else {
            return UITableViewCell()
        }
        let message = frc.object(at: indexPath)
        var avatarID = User.current.avatarID
        if let senderID = message.sender {
            avatarID = cm.avatarForSender(senderID: senderID)
        }
        cell.set(message, avatarID: avatarID)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//  MARK: - NSFetchedResultsControllerDelegate
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
//            cell.set(frc.object(at: idp))
        case .delete:
            guard let idp = indexPath else { return }
            table.deleteRows(at: [idp], with: .automatic)
        @unknown default: break
        }
    }
}
