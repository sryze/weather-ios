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
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationField: UITextField!
    
    private var locationManager = CLLocationManager()
    private var location: CLLocation?
    private var weatherClient = WeatherClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        NSTimer.scheduledTimerWithTimeInterval(600,
            target: self,
            selector: Selector("performScheduledWeatherUpdate"),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.distanceFilter = 10_000
            self.locationManager.startUpdatingLocation()
        }
        
        self.placeNameLabel.hidden = true
        self.temperatureLabel.hidden = true
        self.activityIndicator.startAnimating()
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
            print("Obtained device location: \(location)")
            
            // Stop high-precision location updates after obtaining the initial location. Subsequent
            // updates will come from significant location changes.
            if self.location == nil {
                self.locationManager.stopUpdatingLocation()
                self.locationManager.startMonitoringSignificantLocationChanges()
            }
            self.location = location
            
            print("Fetching weather for (\(location.coordinate.latitude), \(location.coordinate.longitude)")
            weatherClient.fetchWeatherForCoordinate(location.coordinate, handler: self.finishUpdatingWeather)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, ErrorType) in
                if let placemark = placemarks?.last,
                       city = placemark.locality,
                       country = placemark.country {
                    self.placeNameLabel.text =  "\(city), \(country)"
                    self.placeNameLabel.hidden = false
                }
            })
        }
    }
    
    func performScheduledWeatherUpdate() {
        if let location = self.location {
            print("Performing scheduled weather update")
            weatherClient.fetchWeatherForCoordinate(location.coordinate, handler: self.finishUpdatingWeather)
        } else {
            print("Skipping scheduled weather update beacuse location is unknown")
        }
    }
    
    @IBAction func updateLocation() {
        if let locationQuery = self.locationField.text where !locationQuery.isEmpty {
            self.locationField.text = nil
            self.locationField.resignFirstResponder()
            
            let placeName = locationQuery.capitalizedString
            self.placeNameLabel.text = placeName
            
            self.temperatureLabel.hidden = true
            self.activityIndicator.startAnimating()
            
            print("Fetching weather for \(placeName)")
            weatherClient.fetchWeatherForLocation(locationQuery, handler: self.finishUpdatingWeather)
        }
    }
    
    private func finishUpdatingWeather(result: WeatherResult) {
        self.activityIndicator.stopAnimating()
        self.temperatureLabel.hidden = false
        
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