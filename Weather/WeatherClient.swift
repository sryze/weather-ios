//
//  WeatherClient.swift
//  Weather
//
//  Created by Sergey on 22/01/16.
//  Copyright © 2016 Sergey Zolotarev. All rights reserved.
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
    let temperature: Double?
    /// Current temperature in to Celsius degrees.
    var temperatureInCelsius: Double? {
        if let temperature = self.temperature {
            return temperature - 273.15
        }
        return nil
    }
    /// Current temperature in to Farenheit degrees.
    var temperatureInFarenheit: Double? {
        if let temperatureInCelsius = self.temperatureInCelsius {
            return temperatureInCelsius * 1.8  + 32
        }
        return nil
    }
    
    /// Current humidity (unused).
    let humidity: Double?
    /// Current pressure (unused).
    let pressure: Double?
    
    var description: String {
        return "<WeatherData: temperature=\(String(describing: self.temperature)), humidity=\(String(describing: self.humidity)), pressure=\(String(describing: self.pressure))>"
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
    func fetchWeatherForLocation(location: WeatherLocation, handler: @escaping (WeatherResult) -> Void) {
        switch location {
            case .Precise(let coordinate):
                self.fetchWeatherWithParameters(parameters: ["lat": coordinate.latitude as AnyObject, "lon": coordinate.longitude as AnyObject], handler: handler)
            case .Address(let query):
                self.fetchWeatherWithParameters(parameters: ["q": query as AnyObject], handler: handler)
        }
    }
    
    /// A generic method for fetching current weather data with arbitrary query parameters.
    ///
    /// - Parameter parameters: The request parameters. See [OpenWeatherMap API documentation](http://openweathermap.org/current)
    ///                         for possible values.
    /// - Parameter handler: A callback invoked when the request is complete.
    ///
    /// - SeeAlso: `fetchWeatherForLocation(_:handler:)`
    func fetchWeatherWithParameters(parameters: [String: AnyObject], handler: @escaping (WeatherResult) -> Void) {
        var finalParameters = parameters
        finalParameters["APPID"] = self.APIKey as AnyObject
        
        Alamofire.request(WeatherClient.APIBaseURL, method: .get, parameters: finalParameters).responseJSON { response in
            switch response.result {
                case .success(let value):
                    switch WeatherClient.resultFromResponse(rawData: value as! [String: AnyObject]) {
                        case .Success(let data):
                            handler(WeatherResult.Success(data: data))
                        case .Failure(let code, let message):
                            let error = NSError(domain: WeatherErrorDomain, code: WeatherError.APIFailure.rawValue, userInfo: [
                                NSLocalizedDescriptionKey: "API returned error \(code): \(message)"
                            ])
                            handler(WeatherResult.Failure(error))
                    }
                case .failure(let error):
                    handler(WeatherResult.Failure(error as NSError))
            }
        }
    }
    
    private static func resultFromResponse(rawData: [String: AnyObject]) -> Result {
        if let errorCode = rawData["cod"], let errorMessage = rawData["message"] {
            return Result.Failure(String(describing: errorCode), String(describing: errorMessage))
        } else {
            let data = WeatherData(
                temperature: rawData["main"]?["temp"] as? Double,
                humidity: rawData["main"]?["humidity"] as? Double,
                pressure: rawData["main"]?["pressure"] as? Double)
            return Result.Success(data)
        }
    }
}
