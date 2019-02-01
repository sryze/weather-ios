//
//  AppDelegate.swift
//  Weather
//
//  Created by Sergey on 22/01/16.
//  Copyright © 2016 Sergey Zolotarev. All rights reserved.
//

import IQKeyboardManagerSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        return true
    }
}
