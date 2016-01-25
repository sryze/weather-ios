//
//  LocationManagerDelegate.swift
//  Weather
//
//  Created by Sergey on 25/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import CoreLocation
import Foundation

class LocationManagerDelegate : NSObject, CLLocationManagerDelegate {
    let callback: (CLLocation) -> Void
    
    init(_ callback: (CLLocation) -> Void) {
        self.callback = callback
        super.init()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.callback(location)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed with error: \(error)")
    }
}