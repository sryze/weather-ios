//
//  SettingsManager.swift
//  Weather
//
//  Created by Sergey on 10/02/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import Foundation

class Settings {
    enum TemperatureScale: String {
        case Kelvin
        case Celsius
        case Farenheit
    }
    
    let userDefaults: UserDefaults
    
    var temperatureScale: TemperatureScale {
        get {
            let scale = self.userDefaults.string(forKey: "TemperatureScale") ?? TemperatureScale.Kelvin.rawValue
            return TemperatureScale(rawValue: scale)!
        }
        set {
            self.userDefaults.setValue(newValue.rawValue, forKey: "TemperatureScale")
        }
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    convenience init() {
        self.init(userDefaults: UserDefaults.standard)
    }
}
