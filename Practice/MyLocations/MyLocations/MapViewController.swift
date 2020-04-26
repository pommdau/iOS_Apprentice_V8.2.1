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
    var locations = [Location]()  // NSFetchedResultsControllerを使えば簡単だが、あえて手動で実装してみる
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
    }
    
    
    // MARK:- Actions
    @IBAction func showUser() {
        let region = MKCoordinateRegion(
            center: mapView.userLocation.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(region),
                          animated: true)
    }
    
    @IBAction func showLocations() {
        
    }
    
    
    // MARK:- Heloper methods
    // CoreDataに変更があった際に、データを再読み込みしてMapを更新する
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)  // 失敗しないと確信があるならばtry!と書ける
        mapView.addAnnotations(locations)
    }
}

extension MapViewController: MKMapViewDelegate {
    
}
