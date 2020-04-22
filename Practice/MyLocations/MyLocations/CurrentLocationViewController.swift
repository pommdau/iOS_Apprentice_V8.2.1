//
//  FirstViewController.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/22.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()  // CoreLocationを使用するためのオブジェクト
    var location: CLLocation?  // 現在地
    var updatingLocation = false
    var lastLocationError: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }


    // MARK:- Actions
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        // .notDetermined: まだ許可をリクエストしていない場合
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            messageLabel.text = "Tap 'Get My Location' to Start"
            var statusMessage = ""
            if let error = lastLocationError as NSError? {  // エラー情報をチェック
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {  // 位置情報サービスが許可されていない場合
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {  // システム的に位置情報サービスが使用できない場合
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                messageLabel.text = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    // MARK:- Helper Methods
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}


// MARK:- CLLocationManagerDelegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // e.g. didFailWithError The operation couldn’t be completed. (kCLErrorDomain error 1.)
        // This Error object has a domain and a code.
        // The domain in this case is kCLErrorDomain meaning the error came from Core Location (CL). The code is 1,
        // also identified by the symbolic name CLError.denied, which means the user did not allow the app to obtain location information.
        print("didFailWithError \(error.localizedDescription)")
        
        // CLError.locationUnknown — the location is currently unknown, but Core Location will keep trying.
        // CLError.denied — the user denied the app permission to use location services.
        // CLError.network — there was a network-related error.
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        location = newLocation
        updateLabels()
    }
    
}

