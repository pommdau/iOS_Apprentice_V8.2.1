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
        
        // 最初に表示するときにLocationが保存されていればその情報を表示する
        if !locations.isEmpty {
            showLocations()
        }
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
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    // pinの(i)ボタン押下時のアクション
    @objc func showLocationDetails(_ sender: UIButton) {
        
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
    
    // Annotaionsに応じた範囲を返す
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        // Annotaionsがない場合はユーザの位置を中心にする
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
            
        // Annotationsが1つのとき、そこを中心とする
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(center: annotation.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
            
            // Annotaionsが複数ある場合
        // 範囲を計算して
        default:
            var topLeft     = CLLocationCoordinate2D(latitude: -90, longitude: 180)   // 最も左上から遠い右下の点が初期設定
            var bottomRight = CLLocationCoordinate2D(latitude: 90,  longitude: -180)  //
            
            for annotation in annotations {
                topLeft.latitude      = max(topLeft.latitude,      annotation.coordinate.latitude)
                topLeft.longitude     = min(topLeft.longitude,     annotation.coordinate.longitude)
                bottomRight.latitude  = min(bottomRight.latitude,  annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D (
                latitude : topLeft.latitude  - (topLeft.latitude  - bottomRight.latitude)  / 2,
                longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2
            )
            
            let extraSpace = 1.1  // 範囲には少し余裕を持たせる
            let span = MKCoordinateSpan(
                latitudeDelta : abs(topLeft.latitude  - bottomRight.latitude)  * extraSpace,
                longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace
            )
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
    }
    
}


extension MapViewController: MKMapViewDelegate {
    // カスタムのピンを作成する
    // TableView_DataSourceのcellForRowAt的なやつ。
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {  // 型チェックの書き方
            // Location以外の例として、ユーザ位置を示す青い点がある
            // nilを返した場合はデフォルトのものが表示される
            return nil
        }
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {  // 再利用できない場合は新規に作成
            // 緑のピンを作成する
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled      = true
            pinView.canShowCallout = true
            pinView.animatesDrop   = false
            pinView.pinTintColor   = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            
            // Detail disclosureボタン(i)を作成して、pinのaccessoryViewに追加する
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails(_:)), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            
            // ピンの(i)ボタンにタグをつけておく。ボタン押下時後の処理のため。
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.firstIndex(of: annotation as! Location) {
                button.tag = index
            }
        }
        
        return annotationView
    }
}
