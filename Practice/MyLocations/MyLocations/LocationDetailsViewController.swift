//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/22.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

// lazy loading
// DateFormatterはコストが大きいので必要なときに作成し、その後再利用する
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()


class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    // TODO: widthは決まっているので、Heightを計算で動的にしても良い。
    // You get the aspect ratio by doing image.size.width / image.size.height.
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var image: UIImage?
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    
    // LocationsViewControllerからEditとしてsegueされた場合
    var locationToEdit: Location? {  // コレが設定されていればEditモードとする
        didSet {  // locationToEditが設定された際、同時に他のプロパティに値をセットする
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    var observer: Any!  // 監視を解除するためのプロパティ
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 編集モードのときタイトルを変更する
        if let location = locationToEdit {
            title = "Edit Location"
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        listenForBackgroundNotification()
    }
    
    deinit {
        // Do note that as of iOS 9.0 and above, even if you do not remove the observer explicitly,
        // the system would handle this for you and automatically remove the observer when the view controller is deallocated.
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer!)
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    
    // MARK:- Actions
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        let location: Location
        if let temp = locationToEdit {  // 編集モードのとき
            hudView.text = "Updated"
            location = temp
        } else {  // 新規に情報を追加する場合
            hudView.text = "Tagged"
            // NSManagedObject（Locationエンティティ）を作成する
            location = Location(context: managedObjectContext)
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        do {
            try managedObjectContext.save()
            afterDelay(0.6, run: {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            })
            
            //        // さらに以下の書き方も可能: trailing closure syntax
            //        // closureが最後のパラメーターのときに可能
            //        afterDelay(0.6) {
            //            hudView.hide()
            //            self.navigationController?.popViewController(animated: true)
            //        })
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // for unwind segue
    // CategoryPickerViewControllerからこのクラスに戻ってくるときに呼ばれる
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    // MARK:- Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " " }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " " }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)  // タップした座標を取得
        let indexPath = tableView.indexPathForRow(at: point)  // タップした座標のindexPathを取得
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()  // Descriptionのセル以外を選択したときにキーボードを隠す
    }
    
    // 変数のimageにdidSetを使えば自動で画像をアップデートできる（課題）
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        imageHeight.constant = 260
        tableView.reloadData()
    }
    
    // アラートのシート画面は、ホーム画面に戻った際に隠す必要がある（何に関するシートか分からなくなってしまうため）
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] _ in
                // ownership cycleを防ぐためにweakでselfをcaptureする
                // そのためselfがnilになる可能性があるので、unwrap処理が必要
                if let weakSelf = self {
                    if weakSelf.presentedViewController != nil {  // モーダル画面、例えばimage pickerやaction sheetがあれば隠す
                        weakSelf.dismiss(animated: false, completion: nil)
                    }
                    weakSelf.descriptionTextView.resignFirstResponder()  // text viewがアクティブでキーボードが表示されていれば隠す
                }
        }
    }
    
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {  // 選択可能なセクションの指定
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {  // Descriptionを選択した際にキーボードを表示する
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {  // Add Photoが選択された場合
            tableView.deselectRow(at: indexPath, animated: true)  // 選択状態（背景がgray）を解除する
            pickPhoto()
        }
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK:- Image Helper Methods
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary  // 写真フォルダから画像を選択
        imagePicker.delegate = self
        imagePicker.allowsEditing = true  // 編集を可能とする
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 画像を取得する
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {  // カメラがデバイスに存在するかどうか
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }

    // 画像の取得方法をユーザに選択させる
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.takePhotoWithCamera()
        })
        alert.addAction(actPhoto)
        
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary()
        })
        alert.addAction(actLibrary)
        
        // iPad用に下記の設定が必要。またこの処理はiPhoneには影響しない。
        // https://re-engines.com/2017/11/01/swiftipad%E3%81%AEactionsheet%E8%A1%A8%E7%A4%BA%E3%81%A7%E3%82%AF%E3%83%A9%E3%83%83%E3%82%B7%E3%83%A5%E3%81%99%E3%82%8B%E5%95%8F%E9%A1%8C/
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.frame.size.width/2,
                                                                 y: view.frame.size.height,
                                                                 width: 0,
                                                                 height: 0)

        present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // infoからUIImageの情報を取得する
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let theImage = image {
            show(image: theImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
