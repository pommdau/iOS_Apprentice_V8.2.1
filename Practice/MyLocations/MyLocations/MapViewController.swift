//
//  MapViewController.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/26.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    // MARK:- Actions
    @IBAction func showUser() {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(region),
                          animated: true)
    }
    
    @IBAction func showLocations() {
        
    }
}

extension MapViewController: MKMapViewDelegate {
    
}
