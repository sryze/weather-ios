//
//  AppDelegate.swift
//  Weather
//
//  Created by Sergey on 22/01/16.
//  Copyright © 2016 Sergey Zolotarev. All rights reserved.
//

import Mapbox
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        MGLAccountManager.accessToken =
            PrivateInfo.dictionary["MGLMapboxAccessToken"] as? String
        return true
    }
}
