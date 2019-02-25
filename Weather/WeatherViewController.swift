//
//  WeatherViewController.swift
//  Weather
//
//  Created by Sergey on 22/01/16.
//  Copyright © 2016 Sergey Zolotarev. All rights reserved.
//

import CoreLocation
import UIKit

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    private let locationManager = CLLocationManager()
    private let weatherClient = WeatherClient(APIKey: "df8126a16e5ad6f20b8185627628b7f5")
    private let geocoder = CLGeocoder()
    
    private var city: String?
    private var country: String?
    private var receivedInitialLocation = false
    private var weatherLocation: WeatherLocation?
    private var weatherData: WeatherData?
    
    private var settings: Settings = {
        return Settings()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButton.layer.borderColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.802547089)
        updateButton.layer.borderWidth = 1
        updateButton.layer.cornerRadius = 5
        updateButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        if let savedAddress = settings.address {
            updateLocation(fromAddress: savedAddress, completionHandler: nil)
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        Timer.scheduledTimer(timeInterval: 600,
            target: self,
            selector: #selector(performScheduledWeatherUpdate),
            userInfo: nil,
            repeats: true)
        
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.distanceFilter = 10_000
            locationManager.startUpdatingLocation()
        }
        
        cityButton.isHidden = true
        countryLabel.isHidden = true
        temperatureLabel.alpha = 0
        loadingLabel.isHidden = false
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let weatherData = weatherData {
            updateWeather(data: weatherData)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        if !CLLocationManager.locationServicesEnabled() {
            let alertController = UIAlertController(
                title: "Error",
                message: "Location services are not enabled on this device",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == locationField {
            updateLocation()
            view.endEditing(true)
        }
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Obtained device location: \(location)")
            
            // Stop high-precision location updates after obtaining the initial location. Subsequent
            // updates will come from significant location changes.
            if !receivedInitialLocation {
                locationManager.stopUpdatingLocation()
                locationManager.startMonitoringSignificantLocationChanges()
                receivedInitialLocation = true
            }
            
            weatherLocation = .Precise(location.coordinate)
            print("Fetching weather for \(weatherLocation!)")
            weatherClient.fetchWeather(forLocation: weatherLocation!, handler: { result in
                self.finishFetchingWeather(result: result)
            })
            
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let placemark = placemarks?.last,
                   let city = placemark.locality,
                   let country = placemark.country {
                    self.cityButton.setTitle(city, for: .normal)
                    self.cityButton.isHidden = false
                    self.countryLabel.text = country
                    self.countryLabel.isHidden = false
                    self.loadingLabel.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
    @objc func performScheduledWeatherUpdate() {
        if let weatherLocation = weatherLocation {
            print("Performing scheduled weather update")
            weatherClient.fetchWeather(forLocation: weatherLocation, handler: { result in
                self.finishFetchingWeather(result: result)
            })
        } else {
            print("Skipping scheduled weather update beacuse location is unknown")
        }
    }
    
    @objc private func handleKeyboardWillShow(notification: Notification) {
        if let keyboardBounds = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            let textFieldRectInScrollView = locationField.convert(locationField.bounds, to: scrollView)
            let textFieldKeyboardOffset =
                keyboardBounds.height - scrollView.frame.height + textFieldRectInScrollView.maxY + 16
            scrollView.setContentOffset(CGPoint(x: 0, y: textFieldKeyboardOffset), animated: true)
        }
    }
    
    @objc private func handleKeyboardWillHide(notification: Notification) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    private func updateLocation(fromAddress address: String, completionHandler: ((_ success: Bool) -> Void)?) {
        locationField.text = nil
        cityButton.isHidden = true
        countryLabel.isHidden = true
        temperatureLabel.alpha = 0
        loadingLabel.isHidden = false
        activityIndicator.startAnimating()
        
        let failureHandler = {
            self.cityButton.isHidden = false
            self.countryLabel.isHidden = false
            self.loadingLabel.isHidden = true
            self.temperatureLabel.alpha = 1
            self.activityIndicator.stopAnimating()
            
            let alertController = UIAlertController(
                title: "Error",
                message: "Sorry, we could not find a place named \"\(address)\".",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            completionHandler?(false)
        }
        
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                failureHandler()
                return
            }
            
            guard let placemark = placemarks?.last,
                  let city = placemark.locality,
                  let country = placemark.country,
                  let location = placemark.location else {
                failureHandler()
                return
            }
            
            self.city = city
            self.country = country
            self.cityButton.setTitle(city, for: .normal)
            self.cityButton.isHidden = false
            self.countryLabel.text = country
            self.countryLabel.isHidden = false
            self.loadingLabel.isHidden = true
            
            self.weatherLocation = .Precise(location.coordinate)
            print("Fetching weather for \(self.weatherLocation!)")

            self.weatherClient.fetchWeather(forLocation: self.weatherLocation!, handler: { result in
                let success = self.finishFetchingWeather(result: result)
                completionHandler?(success)
            })
        })
    }
    
    @IBAction func handleScrollViewTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func showCity(_ sender: Any) {
    }
    
    @IBAction func updateLocation() {
        view.endEditing(true)
        
        if let address = locationField.text, !address.isEmpty {
            updateLocation(fromAddress: address, completionHandler: { success in
                if success {
                    self.settings.address = address
                }
            })
        }
    }
    
    @discardableResult private func finishFetchingWeather(result: WeatherResult) -> Bool {
        activityIndicator.stopAnimating()
        temperatureLabel.alpha = 1
        
        switch result {
            case .Success(let data):
                print("Successfully fetched weather data: \(data)")
                weatherData = data
                updateWeather(data: data)
                return true
            case .Failure(let error):
                print("Failed to fetch weather data: \(error)")
                let alertController = UIAlertController(
                    title: "Error",
                    message: "Sorry, we could not obtain weather information for this city.",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil))
                present(alertController, animated: true, completion: nil)
                return false
        }
    }
    
    private func updateWeather(data: WeatherData) {
        temperatureLabel.text = {
            switch settings.temperatureScale {
                case _ where data.temperature == nil:
                    return "Hmm... 🤔"
                case .Celsius:
                    return String(format: "%+.0f °C", round(data.temperatureInCelsius!))
                case .Farenheit:
                    return String(format: "%+.0f °F", round(data.temperatureInFarenheit!))
                default:
                    return String(format: "%.1f K", data.temperature!)
            }
        }()
    }
}
