//
//  CityViewController.swift
//  Weather
//
//  Created by Sergey on 25/02/2019.
//  Copyright © 2019 Sergey Zolotarev. All rights reserved.
//

import MapKit
import UIKit

class CityViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    var city: String?
    var country: String?
    var location: CLLocation?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let location = location {
            mapView.centerCoordinate = location.coordinate
            mapView.region = MKCoordinateRegion(
                center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)

            let cityAnnotation = MKPointAnnotation()
            cityAnnotation.coordinate = location.coordinate
            cityAnnotation.title = city
            cityAnnotation.subtitle = country
            mapView.addAnnotation(cityAnnotation)
        }
    }
}
