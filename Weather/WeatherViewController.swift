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
    
    private var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
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
            let alertController = UIAlertController(
                title: "Error",
                message: "Location services are not enabled on this device",
                preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .Default,
                handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.locationField {
            self.updateLocation()
        }
        return true
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager failed with error: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            WeatherClient().fetchWeatherForCoordinate(location.coordinate, handler: self.completeUpdatingWeather)
        }
    }
    
    @IBAction func updateLocation() {
        if let locationQuery = self.locationField.text where !locationQuery.isEmpty {
            self.startUpdatingWeather()
            self.locationField.resignFirstResponder()
            self.locationField.text = nil
            WeatherClient().fetchWeatherForLocation(locationQuery, handler: self.completeUpdatingWeather)
        }
    }
    
    private func startUpdatingWeather() {
        self.temperatureLabel.hidden = true;
        self.activityIndicator.startAnimating()
    }
    
    private func stopUpdatingWeather() {
        self.activityIndicator.stopAnimating()
        self.temperatureLabel.hidden = false;
    }
    
    private func completeUpdatingWeather(result: WeatherResult) {
        self.stopUpdatingWeather()
        
        switch result {
            case .Success(let data):
                self.temperatureLabel.text = String(format: "%+.0f °C", round(data.temperatureInCelsius))
            case .Failure(let error):
                let alertController = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .Default,
                    handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}