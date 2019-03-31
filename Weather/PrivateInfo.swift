//
//  PrivateInfo.swift
//  Weather
//
//  Created by Sergey on 31/03/2019.
//  Copyright © 2019 Sergey Zolotarev. All rights reserved.
//

import Foundation

class PrivateInfo {

    static var dictionary: NSDictionary = {
        let path = Bundle.main.path(forResource: "PrivateInfo", ofType: "plist")!
        let dictionary = NSDictionary(contentsOfFile: path)
        return dictionary!
    }()
}
