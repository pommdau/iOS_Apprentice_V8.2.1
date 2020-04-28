//
//  FirstViewController.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/22.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!  // 上部に表示するUIパーツを色々纏めたもの
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
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

    var timer: Timer?  // 検索後60sでタイムアウトとする
    var managedObjectContext: NSManagedObjectContext!  // LocaritonDetailsViewControllerに渡す用
    var logoVisible = false  // ロゴを表示するかどうか
    
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
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
        
        // メインのロゴボタンを隠して"Searching..."を表示する
        if logoVisible {
            hideLogoView()
        }
        
        if updatingLocation {  // Stopの場合
            stopLocationManager()
        } else {
            // Location
            location = nil
            lastLocationError = nil
            
            // Reverse Geocoding
            placemark = nil
            lastGeocodingError = nil
            
            startLocationManager()  // Get My Locationの場合
        }
        updateLabels()
    }
    
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate  // Tag Locationボタンはlocationがあるときのみ有効になるので、unwrapは安全
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    
    // MARK:- Helper Methods
    func showLogoView() {
        if !logoVisible {
            logoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        if !logoVisible { return }
        
        logoVisible = false
        containerView.isHidden = false
        
        // 位置情報のUIの始点を設定
        // 最終的に、右端から左にスライドさせて表示する
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        // アニメーションでロゴボタンを隠す
        // アニメーション完了後はDelegateメソッドの、func animationDidStop(_ anim: CAAnimation, finished flag: Bool)が呼ばれる
        let centerX = view.bounds.midX
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode              = CAMediaTimingFillMode.forwards
        panelMover.duration              = 0.6
        panelMover.fromValue             = NSValue(cgPoint: containerView.center)
        panelMover.toValue               = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction        = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        panelMover.delegate              = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode              = CAMediaTimingFillMode.forwards
        logoMover.duration              = 0.5
        logoMover.fromValue             = NSValue(cgPoint: logoButton.center)
        logoMover.toValue               = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction        = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode              = CAMediaTimingFillMode.forwards
        logoRotator.duration              = 0.5
        logoRotator.fromValue             = 0.0
        logoRotator.toValue               = -2 * Double.pi
        logoRotator.timingFunction        = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }
    
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
            
            // 検索後60sでタイムアウトとする
            timer = Timer.scheduledTimer(timeInterval: 60,
                                         target: self,
                                         selector: #selector(didTimeOut),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
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
            
            // 座標が取得できていれば結果を表示
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
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
                statusMessage = ""
                showLogoView()
            }
            messageLabel.text = statusMessage
            // 座標が取得できていない場合は結果を非表示
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
        }
        configureGetButton()
    }
    
    func configureGetButton() {
        let spinnerTag = 1000  // PropertyでもいいがTagで管理すると、一箇所でまとめられる利点がある
        
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            
            // スピナーがまだない場合は作成して表示
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(style: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height/2 + 25
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Locatoin", for: .normal)
            
            // スピナーがあればビューから削除
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")

        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode,         separatedBy: " ")
        
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }
    
    @objc func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
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
        
        // 新しい地点と前回の地点の距離を計測
        // 前回の地点がない場合はDoubleの最大値とする
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            // 精度は数値が小さいほど正確。
            // e.g. +-10m < +-100m
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                
                // 常に新しい座標でreverse geocodingを行う
                // falseにすることで既にreverse geocodingしているときも、改めてreverse geocodingを始めるようになる
                // distanceが0の場合は同じ場所なので、改めて行う必要はない
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            updateLabels()
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: { placemarks, error in
                    self.lastGeocodingError = error
                    
                    // reverse geocodingに成功した場合
                    if error == nil, let p = placemarks, !p.isEmpty {
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
        else if distance < 1 {  // 前回との距離がほぼ変わらない場合（誤差により0となることは無いので1としている）
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {  // また10s以上経っている場合、計測を完了とする（e.g. iPodなどで精度が出ない場合）
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
        }
    }
}


// MARK:- Animation Delegate Methods
extension CurrentLocationViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
}
