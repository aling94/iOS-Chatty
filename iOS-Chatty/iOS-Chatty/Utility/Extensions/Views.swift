//
//  Views.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/11/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        
        set {
            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        
        set {
            layer.borderWidth = newValue
//            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get { return UIColor(cgColor: layer.borderColor!) }
        
        set { layer.borderColor = newValue.cgColor }
    }
    
    @IBInspectable var clipToBounds: Bool {
        get { return clipsToBounds }
        set { clipsToBounds = newValue }
    }
}

extension UIColor {
    
    static var lightBlue: UIColor {
        return UIColor(red: 0, green: 122/255.0, blue: 1, alpha: 1)
    }
    
    static var lightGreen: UIColor {
        return UIColor(red: 37/255.0, green: 188/255.0, blue: 109/255.0, alpha: 1)
    }
}
