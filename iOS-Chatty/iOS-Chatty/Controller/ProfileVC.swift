//
//  ProfileVC.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var avatarImage: UIImageView!
    
    var isUpdating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        nameField.text = User.current.name
        avatarImage.image = UIImage.avatar(id: User.current.avatarID)
    }
    
    func transition() {
        if isUpdating {
            navigationController?.popViewController(animated: true)
        } else {
            guard let vc = storyboard?.instantiateViewController(withIdentifier:
                String(describing: UserListVC.self)) as? UserListVC else { return }
            
            vc.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }


    @IBAction func saveProfile(_ sender: Any) {
        if let name = nameField.text, !name.isEmpty, User.current.avatarID > 0 {
            User.current.name = name
            User.current.save()
            showAlert(title: "Notice", message: "Preferences have been saved.") { [weak self] _ in
                self?.transition()
            }
            
        } else {
            showAlert(title: "Incomplete", message: "Please fill out your name and pick an avatar.")
        }
    }
    
    //  MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? AvatarPickerVC else { return }
        vc.selectAction = { [unowned self] avatarID in
            User.current.avatarID = avatarID
            self.avatarImage.image = UIImage.avatar(id: avatarID)
        }
    }
}

extension ProfileVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
