//
//  CityViewController2.swift
//  Weather
//
//  Created by Sergey on 18/03/2019.
//  Copyright © 2019 Sergey Zolotarev. All rights reserved.
//

import CoreLocation
import UIKit
import Mapbox

class CityViewController2: UIViewController, MGLMapViewDelegate {

    @IBOutlet weak var mapView: MGLMapView!

    var city: String?
    var country: String?
    var location: CLLocation?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let location = location {
            let cityAnnotation = MGLPointAnnotation()
            cityAnnotation.coordinate = location.coordinate
            cityAnnotation.title = city
            cityAnnotation.subtitle = country
            mapView.addAnnotation(cityAnnotation)
            mapView.centerCoordinate = cityAnnotation.coordinate
        }
    }

    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}
