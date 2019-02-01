//
//  SettingsManager.swift
//  Weather
//
//  Created by Sergey on 10/02/16.
//  Copyright © 2016 Sergey Zolotarev. All rights reserved.
//

import Foundation

class Settings {
    enum TemperatureScale: String {
        case Kelvin
        case Celsius
        case Farenheit
    }
    
    let userDefaults: UserDefaults
    
    var defaultTemperatureScale: TemperatureScale {
        if let localization = Bundle.main.preferredLocalizations.first {
            switch (localization) {
            case "en_US":
                return TemperatureScale.Farenheit
            default:
                return TemperatureScale.Celsius
            }
        }
        return TemperatureScale.Celsius
    }
    
    var temperatureScale: TemperatureScale {
        get {
            let scale = self.userDefaults.string(forKey: "TemperatureScale") ?? self.defaultTemperatureScale.rawValue
            return TemperatureScale(rawValue: scale)!
        }
        set {
            self.userDefaults.setValue(newValue.rawValue, forKey: "TemperatureScale")
        }
    }
    
    var address: String? {
        get {
            return self.userDefaults.string(forKey: "Address")
        }
        set {
            self.userDefaults.setValue(newValue, forKey: "Address")
        }
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    convenience init() {
        self.init(userDefaults: UserDefaults.standard)
    }
}
