//
//  ViewController.swift
//  Weather
//
//  Created by Sergey on 22/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import CoreLocation
import UIKit

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationField: UITextField!
    
    private var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            self.locationManager.startMonitoringSignificantLocationChanges()
        } else {
            self.locationManager.distanceFilter = 10_000
            self.locationManager.startUpdatingLocation()
        }
        
        self.startUpdatingWeather()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !CLLocationManager.locationServicesEnabled() {
            let alertController = UIAlertController(title: "Error", message: "Location services are not enabled on this device", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.locationField {
            self.changeLocation()
        }
        return true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            WeatherClient().fetchWeatherData(forCoordinate: location.coordinate, callback: { data in
                self.temperatureLabel.text = String(format: "%.0f °C", round(data.temperature))
                self.stopUpdatingWeather()
            })
        }
    }
    
    @IBAction func changeLocation() {
        if let locationQuery = self.locationField.text where locationQuery.characters.count != 0 {
            self.startUpdatingWeather()
            self.locationField.resignFirstResponder()
            self.locationField.text = nil
            
            WeatherClient().fetchWeatherData(forLocation: locationQuery, callback: { data in
                self.stopUpdatingWeather()
                self.temperatureLabel.text = String(format: "%.0f °C", round(data.temperature))
            })
        }
    }
    
    func startUpdatingWeather() {
        self.temperatureLabel.hidden = true;
        self.activityIndicator.startAnimating()
    }
    
    func stopUpdatingWeather() {
        self.temperatureLabel.hidden = false;
        self.activityIndicator.stopAnimating()
    }
}