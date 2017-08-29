//
//  AppDelegate.swift
//  WYRefresh
//
//  Created by wenyou on 2016/11/15.
//  Copyright © 2016年 wyrefresh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.screen = UIScreen.main
        window?.rootViewController = UINavigationController(rootViewController: {
            let controller = ViewController();
            controller.title = "table"
            return controller
        }())
        window?.makeKeyAndVisible()

        return true
    }
}
