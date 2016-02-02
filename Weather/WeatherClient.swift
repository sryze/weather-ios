//
//  WeatherClient.swift
//  Weather
//
//  Created by Sergey on 22/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import Alamofire
import CoreLocation

let WeatherErrorDomain = "WeatherErrorDomain"

enum WeatherError: Int {
    case APIFailure
}

enum WeatherResult {
    case Success(WeatherData)
    case Failure(NSError)
}

enum WeatherLocation {
    case Precise(CLLocationCoordinate2D)
    case Address(String)
}

class WeatherData {
    
    let temperature: Double
    var temperatureInCelsius: Double {
        return self.temperature - 273.15
    }
    
    let humidity: Double
    let pressure: Double
    
    private init(rawData: [String: AnyObject]) {
        self.temperature = rawData["main"]!["temp"] as! Double
        self.humidity = rawData["main"]!["humidity"] as! Double
        self.pressure = rawData["main"]!["pressure"] as! Double
    }
}

class WeatherClient {

    private static let APIBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private static let APIKey = "df8126a16e5ad6f20b8185627628b7f5"
    
    func fetchWeatherForLocation(location: WeatherLocation, handler: (WeatherResult) -> Void) {
        switch location {
            case .Precise(let coordinate):
                self.fetchWeather(["lat": coordinate.latitude, "lon": coordinate.longitude], handler: handler)
            case .Address(let query):
                self.fetchWeather(["q": query], handler: handler)
        }
    }
    
    func fetchWeather(parameters: [String: AnyObject], handler: (WeatherResult) -> Void) {
        var finalParameters = parameters;
        finalParameters.updateValue(WeatherClient.APIKey, forKey: "APPID")
        
        Alamofire.request(.GET, WeatherClient.APIBaseURL, parameters: finalParameters).responseJSON { response in
            switch response.result {
                case .Success(let value):
                    let JSON = value as! [String: AnyObject]
                    if let errorCode = JSON["cod"], errorMessage = JSON["message"] {
                        let error = NSError(domain: WeatherErrorDomain, code: WeatherError.APIFailure.rawValue, userInfo: [
                            NSLocalizedDescriptionKey: "API returned error \(errorCode): \(errorMessage)"
                        ])
                        handler(WeatherResult.Failure(error))
                    } else {
                        let data = WeatherData(rawData: JSON)
                        handler(WeatherResult.Success(data))
                    }
                case .Failure(let error):
                    handler(WeatherResult.Failure(error))
            }
        }
    }
}