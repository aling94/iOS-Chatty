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
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func saveProfile(_ sender: Any) {
        if let name = nameField.text, !name.isEmpty {
            User.current.name = name
            User.current.save()
            navigationController?.popViewController(animated: true)
        }
    }
}
