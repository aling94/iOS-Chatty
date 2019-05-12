//
//  UserListVC.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

class UserListVC: UIViewController {
    
    @IBOutlet weak var collection: UICollectionView!
    
    var dm: DeviceManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        dm = DeviceManager(delegate: self)
        dm.begin()
    }
}

extension UserListVC: DeviceManagerDelegate {
    
    func deviceManager(didAddNewPeripheral: Device) {
//        let lastItem = IndexPath(item: self.dm.deviceCount - 1, section: 0)
//        DispatchQueue.main.async {
//            self.collection.insertItems(at: [lastItem])
//        }
    }
    
    func deviceManagerDidUpdateDeviceDesc(at index: Int) {
        DispatchQueue.main.async {
            guard let cell = self.collection.cellForItem(at: IndexPath(item: index, section: 0)) as? UserCell
                else { return }

            cell.set(self.dm.device(at: index))
        }
    }
    
    func deviceManagerDidReload() {
        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }
}

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
    
    
}

extension UserListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.bounds.size.width / 2) - 15
        return CGSize(width: size, height: size + 25)
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
