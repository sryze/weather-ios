//
//  ViewController.swift
//  Weather
//
//  Created by Sergey on 22/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import CoreLocation
import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var locationManager: CLLocationManager!
    private var locationManagerDelegate: LocationManagerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManagerDelegate = LocationManagerDelegate { location in
            WeatherClient().fetchWeatherData(forCoordinate: location.coordinate, callback: { data in
                self.temperatureLabel.hidden = false;
                self.temperatureLabel.text = String(format: "%.0f °C", round(data.temperature))
                self.activityIndicator.stopAnimating()
            })
        }
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self.locationManagerDelegate
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            self.locationManager.startMonitoringSignificantLocationChanges()
        } else {
            self.locationManager.distanceFilter = 10_000
            self.locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.temperatureLabel.hidden = true;
        self.activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !CLLocationManager.locationServicesEnabled() {
            let alertController = UIAlertController(title: "Error", message: "Location services are not enabled on this device", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}