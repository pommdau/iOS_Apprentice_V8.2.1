//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/27.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent  // ステータスバーの文字を白くする設定
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil  // ViewControllerに対して、自身のpreferredStatusBarStyleを適用する設定
    }
}
