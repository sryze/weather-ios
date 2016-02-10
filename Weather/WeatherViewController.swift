//
//  WeatherViewController.swift
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
    
    private let locationManager = CLLocationManager()
    private let weatherClient = WeatherClient(APIKey: "df8126a16e5ad6f20b8185627628b7f5")
    private let geocoder = CLGeocoder()
    
    private var receivedInitialLocation = false
    private var weatherLocation: WeatherLocation?
    private var weatherData: WeatherData?
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let weatherData = self.weatherData {
            self.updateDisplayedWeatherFromData(weatherData)
        }
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
            if !self.receivedInitialLocation {
                self.locationManager.stopUpdatingLocation()
                self.locationManager.startMonitoringSignificantLocationChanges()
                self.receivedInitialLocation = true
            }
            self.weatherLocation = .Precise(location.coordinate)
            
            print("Fetching weather for \(self.weatherLocation!)")
            self.weatherClient.fetchWeatherForLocation(self.weatherLocation!, handler: self.finishFetchingWeather)
            
            self.geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
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
        if let weatherLocation = self.weatherLocation {
            print("Performing scheduled weather update")
            self.weatherClient.fetchWeatherForLocation(weatherLocation, handler: self.finishFetchingWeather)
        } else {
            print("Skipping scheduled weather update beacuse location is unknown")
        }
    }
    
    @IBAction func updateLocation() {
        if let address = self.locationField.text where !address.isEmpty {
            self.locationField.text = nil
            self.locationField.resignFirstResponder()
            
            self.placeNameLabel.hidden = true
            self.temperatureLabel.hidden = true
            self.activityIndicator.startAnimating()
            
            geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
                self.placeNameLabel.hidden = false
                self.placeNameLabel.text = address
                
                if let placemark = placemarks?.last,
                       city = placemark.locality,
                       country = placemark.country,
                       location = placemark.location {
                    self.placeNameLabel.text = "\(city), \(country)"
                    self.weatherLocation = .Precise(location.coordinate)
                } else {
                    self.weatherLocation = .Address(address)
                }
                
                print("Fetching weather for \(self.weatherLocation!)")
                self.weatherClient.fetchWeatherForLocation(self.weatherLocation!, handler: self.finishFetchingWeather)
            })
        }
    }
    
    private func finishFetchingWeather(result: WeatherResult) {
        self.activityIndicator.stopAnimating()
        self.temperatureLabel.hidden = false
        
        switch result {
            case .Success(let data):
                print("Successfully fetched weather data: \(data)")
                self.weatherData = data
                self.updateDisplayedWeatherFromData(data)
            case .Failure(let error):
                print("Failed to fetch weather data: \(error)")
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
    
    private func updateDisplayedWeatherFromData(data: WeatherData) {
        self.temperatureLabel.text = {
            switch Settings().temperatureScale {
                case .Celsius:
                    return String(format: "%+.0f °C", round(data.temperatureInCelsius))
                case .Farenheit:
                    return String(format: "%+.0f °F", round(data.temperatureInFarenheit))
                default:
                    return String(format: "%.1f K", data.temperature)
            }
        }()
    }
}