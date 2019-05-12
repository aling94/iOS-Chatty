//
//  ImageViews.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/12/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import UIKit

extension UIImage {
    static func avatar(id: Int) -> UIImage? {
        return UIImage(named: "\(Constants.avatarPrefix)\(id)")
    }
}
