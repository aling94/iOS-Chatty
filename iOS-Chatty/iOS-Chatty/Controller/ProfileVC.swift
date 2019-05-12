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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = User.current.name
        avatarImage.image = UIImage.avatar(id: User.current.avatarID)
    }


    @IBAction func saveProfile(_ sender: Any) {
        if let name = nameField.text, !name.isEmpty {
            User.current.name = name
            User.current.save()
            showAlert(title: "Notice", message: "Preferences have been saved.") { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            
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
