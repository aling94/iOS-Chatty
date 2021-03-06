//
//  UserListVC.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit
import Pulsator

class UserListVC: UIViewController {
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var chatAllBtn: UIButton!
    @IBOutlet weak var notice: UILabel!
    @IBOutlet weak var signalImage: UIImageView!
    
    var dm: DeviceManager!
    var selectedItems: Set<IndexPath> = []
    let pulsator = Pulsator()

    override func viewDidLoad() {
        super.viewDidLoad()
        collection.allowsMultipleSelection = true
        dm = DeviceManager(delegate: self)
        dm.begin()
        toggleNotice()
        toggleChatAll()
        setupPulsator()
        togglePulsator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationItem.title = User.current.name
        toggleChatBtn(enabled: false)
        dm.updateAdvertisingData()
        reloadNotices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deselectAll()
        pulsator.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        pulsator.position = signalImage.layer.position
    }
    
    func setupPulsator() {
        pulsator.backgroundColor = UIColor.white.cgColor
        pulsator.radius = view.frame.width * 0.6
        pulsator.animationDuration = 10
        pulsator.numPulse = 5
        signalImage.layer.superlayer?.insertSublayer(pulsator, below: signalImage.layer)
    }
    
    func toggleNotice() {
        notice.isHidden = dm.deviceCount > 0
    }
    
    func toggleChatAll() {
        let enabled = dm.deviceCount > 0
        chatAllBtn.isEnabled = enabled
        chatAllBtn.backgroundColor = enabled ? .white : .lightGray
        chatAllBtn.setTitleColor(enabled ? .lightGreen : .white, for: .normal)
    }
    
    func toggleChatBtn(enabled: Bool) {
        chatBtn.isEnabled = enabled
        chatBtn.backgroundColor = enabled ? .lightGreen : .lightGray
    }
    
    func togglePulsator() {
        let hasUsers = dm.deviceCount > 0
        signalImage.isHidden = hasUsers
        if !hasUsers && !pulsator.isPulsating {
            pulsator.start()
        } else if hasUsers {
            pulsator.stop()
        }
        
    }
    
    @IBAction func chatTapped(_ sender: Any) {
        guard !selectedItems.isEmpty,
            let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: ChatVC.self)) as? ChatVC
            else { return }
        
        let filter = selectedItems.map({dm.device(at: $0.item)})
        vc.cm = ChatManager(filter: filter, devices: dm.visibleDevices)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chatAllTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: ChatVC.self)) as? ChatVC
            else { return }
        
        vc.cm = ChatManager(filter: [], devices: dm.visibleDevices)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        deselectAll()
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileVC.self)) as? ProfileVC
            else { return }
        
        vc.isUpdating = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func reloadNotices() {
        DispatchQueue.main.async {
            self.collection.reloadData()
            self.toggleNotice()
            self.toggleChatAll()
            self.togglePulsator()
        }
    }
}

//  MARK: - DeviceManagerDelegate
extension UserListVC: DeviceManagerDelegate {
    
    func deviceManager(didAddNewPeripheral: Device) {
        reloadNotices()
    }
    
    func deviceManagerDidUpdateDeviceDesc(at index: Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = self.collection.cellForItem(at: indexPath) as? UserCell else { return }

            cell.set(self.dm.device(at: index))
            self.collection.reloadItems(at: [indexPath])
        }
    }
    
    func deviceManagerDidReload() {
        reloadNotices()
    }
}


//  MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension UserListVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dm.deviceCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.reuseID, for: indexPath) as? UserCell
            else {
                return UICollectionViewCell()
        }
        cell.set(dm.device(at: indexPath.item))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItems.insert(indexPath)
        if selectedItems.count == 1 {
            toggleChatBtn(enabled: true)
        }
        dm.stopReloads()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedItems.remove(indexPath)
        if selectedItems.isEmpty {
            dm.startReloads()
            toggleChatBtn(enabled: false)
        }
    }
    
    func deselectAll() {
        for indexPath in selectedItems {
            collection.deselectItem(at: indexPath, animated: false)
        }
        selectedItems.removeAll()
        toggleChatBtn(enabled: false)
        dm.startReloads()
    }
    
}

//  MARK: - UICollectionViewDelegateFlowLayout
extension UserListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.bounds.size.width / 2) - 15
        return CGSize(width: size, height: size + 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
