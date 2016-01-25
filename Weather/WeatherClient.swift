//
//  WeatherClient.swift
//  Weather
//
//  Created by Sergey on 22/01/16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import Alamofire
import CoreLocation

class WeatherData {
    
    let temperature: Double
    let humidity: Double
    let pressure: Double
    
    private init(response: Response<AnyObject, NSError>) {
        let JSON = response.result.value!
        self.temperature = WeatherData.toCelsius(JSON["main"]!!["temp"]!! as! Double)
        self.humidity = JSON["main"]!!["humidity"]!! as! Double
        self.pressure = JSON["main"]!!["pressure"]!! as! Double
    }
    
    private static func toCelsius(temperatureInKelvins: Double) -> Double {
        return temperatureInKelvins - 273.15
    }
}

class WeatherClient {

    private static let APIBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private static let APIKey = "df8126a16e5ad6f20b8185627628b7f5"
    
    func fetchWeatherData(forCoordinate coordinate: CLLocationCoordinate2D, callback: (WeatherData) -> Void) {
        Alamofire.request(.GET, WeatherClient.APIBaseURL, parameters: [
            "lat": coordinate.latitude,
            "lon": coordinate.longitude,
            "APPID": WeatherClient.APIKey
        ]).responseJSON { response in
            callback(WeatherData(response: response))
        }
    }
    
    func fetchWeatherData(forLocation location: String, callback: (WeatherData) -> Void) {
        Alamofire.request(.GET, WeatherClient.APIBaseURL, parameters: [
            "q": location,
            "APPID": WeatherClient.APIKey
        ]).responseJSON { response in
            callback(WeatherData(response: response))
        }
    }
}