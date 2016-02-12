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
    case Success(data: WeatherData)
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

struct WeatherData: CustomStringConvertible {
    /// Current temperature as absolute value (i.e. in Kelvin).
    let temperature: Double
    /// Current temperature in to Celsius degrees.
    var temperatureInCelsius: Double {
        return self.temperature - 273.15
    }
    /// Current temperature in to Farenheit degrees.
    var temperatureInFarenheit: Double {
        return self.temperatureInCelsius * 1.8  + 32
    }
    
    /// Current humidity (unused).
    let humidity: Double
    /// Current pressure (unused).
    let pressure: Double
    
    var description: String {
        return "<WeatherData: temperature=\(self.temperature), humidity=\(self.humidity), pressure=\(self.pressure)>"
    }
}

class WeatherClient {
    /// The base URL for the OpenWeatherMap API.
    private static let APIBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    
    /// Represents a response from the OpenWeatherMap API.
    enum Result {
        /// Data response, contains weather data such as temperature, etc.
        case Success(WeatherData)
        /// Error response, contains API error code and message.
        case Failure(String, String)
    }
    
    /// The API key (also known as APPID).
    private let APIKey: String;
    
    /// Initializes the WeatherClient with a given API key (APPID).
    ///
    /// - Parameter APIKey: The API key (APPID) to be used for OpenWeatherMap API requests.
    init(APIKey: String) {
        self.APIKey = APIKey
    }
    
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
        var finalParameters = parameters
        finalParameters["APPID"] = self.APIKey
        
        Alamofire.request(.GET, WeatherClient.APIBaseURL, parameters: finalParameters).responseJSON { response in
            switch response.result {
                case .Success(let value):
                    switch WeatherClient.resultFromResponse(value as! [String: AnyObject]) {
                        case .Success(let data):
                            handler(WeatherResult.Success(data: data))
                        case .Failure(let code, let message):
                            let error = NSError(domain: WeatherErrorDomain, code: WeatherError.APIFailure.rawValue, userInfo: [
                                NSLocalizedDescriptionKey: "API returned error \(code): \(message)"
                            ])
                            handler(WeatherResult.Failure(error))
                    }
                case .Failure(let error):
                    handler(WeatherResult.Failure(error))
            }
        }
    }
    
    private static func resultFromResponse(rawData: [String: AnyObject]) -> Result {
        if let errorCode = rawData["cod"], errorMessage = rawData["message"] {
            return Result.Failure(String(errorCode), String(errorMessage))
        } else {
            let data = WeatherData(
                temperature: rawData["main"]!["temp"] as! Double,
                humidity: rawData["main"]!["humidity"] as! Double,
                pressure: rawData["main"]!["pressure"] as! Double)
            return Result.Success(data)
        }
    }
}