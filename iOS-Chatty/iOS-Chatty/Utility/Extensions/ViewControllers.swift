//
//  ViewControllers.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/12/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, okActionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: okActionHandler))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func hideKeyboardOnScreenTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
