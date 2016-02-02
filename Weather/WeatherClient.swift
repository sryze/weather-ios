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
    /// Weather request succeeded.
    case Success(WeatherData)
    /// Weather request resulted in a nerror.
    case Failure(NSError)
}

enum WeatherLocation: CustomStringConvertible {
    /// Location with exact coordinates (latitude and longitude).
    case Precise(CLLocationCoordinate2D)
    /// Location with an address of place name, e.g. New York.
    case Address(String)
    
    var description: String {
        switch self {
            case .Precise(let coordinate):
                return "<WeatherLocation.Precise: coordinate=(\(coordinate.latitude), \(coordinate.longitude))>"
            case .Address(let address):
                return "<WeatherLocation.Address: address=\(address)>"
        }
    }
}

class WeatherData: CustomStringConvertible {
    /// Current temperature as absolute value (i.e. in Kelvin).
    let temperature: Double
    /// Current temperature converted to Celsius degrees.
    var temperatureInCelsius: Double {
        return self.temperature - 273.15
    }
    
    /// Current humidity (unused).
    let humidity: Double
    /// Current pressure (unused).
    let pressure: Double
    
    private init(rawData: [String: AnyObject]) {
        self.temperature = rawData["main"]!["temp"] as! Double
        self.humidity = rawData["main"]!["humidity"] as! Double
        self.pressure = rawData["main"]!["pressure"] as! Double
    }
    
    var description: String {
        return "<WeatherData: temperature=\(self.temperature), humidity=\(self.humidity), pressure=\(self.pressure)>"
    }
}

class WeatherClient {
    /// The base URL for the OpenWeatherMap API.
    private static let APIBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    /// The API key (also known as APPID).
    private static let APIKey = "df8126a16e5ad6f20b8185627628b7f5"
    
    /// Fetches current weather data at the specified location.
    ///
    /// - Parameter location: The location for which to get weather.
    /// - Parameter handler: A callback invoked when the request is complete.
    ///
    /// - SeeAlso: `fetchWeather(_:handler:)`
    func fetchWeatherForLocation(location: WeatherLocation, handler: (WeatherResult) -> Void) {
        switch location {
            case .Precise(let coordinate):
                self.fetchWeatherWithParameters(["lat": coordinate.latitude, "lon": coordinate.longitude], handler: handler)
            case .Address(let query):
                self.fetchWeatherWithParameters(["q": query], handler: handler)
        }
    }
    
    /// A generic method for fetching current weather data with arbitrary query parameters.
    ///
    /// - Parameter parameters: The request parameters. See [OpenWeatherMap API documentation](http://openweathermap.org/current)
    ///                         for possible values.
    /// - Parameter handler: A callback invoked when the request is complete.
    ///
    /// - SeeAlso: `fetchWeatherForLocation(_:handler:)`
    func fetchWeatherWithParameters(parameters: [String: AnyObject], handler: (WeatherResult) -> Void) {
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