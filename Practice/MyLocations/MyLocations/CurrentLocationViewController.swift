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
    
    // Get Location
    let locationManager = CLLocationManager()  // CoreLocationを使用するためのオブジェクト
    var location: CLLocation?  // 現在地
    var updatingLocation = false
    var lastLocationError: Error?
    
    // Reverce geocoding
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    
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
        
        if updatingLocation {  // Stopの場合
            stopLocationManager()
        } else {
            // Location
            location = nil
            
            // Reverse Geocoding
            placemark = nil
            lastGeocodingError = nil

            startLocationManager()  // Get My Locationの場合
            updateLabels()
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
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
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
            
            // Locationが見つかっている場合、Addressの現在の情報を表示する
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
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
        configureGetButton()
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Locatoin", for: .normal)
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s
        }
        
        return line1 + "\n" + line2
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
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {  // 5秒よりも前の情報は無視する。すぐに次の結果は取得できるので単純にreturnでOK
            return
        }
        
        // horizontalAccuracy: 計測の正確さを表す
        // 負の値の場合はinvalidなので無視する
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            // 精度は数値が小さいほど正確。
            // e.g. +-10m < +-100m
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("we're done!")
                stopLocationManager()
            }
            updateLabels()
            
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation,
                                                completionHandler:
                    { placemarks, error in
                        self.lastGeocodingError = error
                        if error == nil, let p = placemarks, !p.isEmpty {
                            // reverse geocodingに成功した場合
                            self.placemark = p.last!
                        } else {
                            // 失敗した場合、すでに（過去の）情報があればそれを破棄する
                            self.placemark = nil
                        }
                        
                        self.performingReverseGeocoding = false
                        self.updateLabels()
                })
            }
        }
    }
}

