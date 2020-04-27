//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/23.
//  Copyright © 2020 hikeuchi. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

// (Location)はName mangling
// SwfitとObjective-Cが混ざっているプロジェクトの場合、コンパイルでうまくいかなくなる可能性がある
// Objective-C側にSwiftでLocationクラスがあるよ、と伝えている感じかな
@objc(Location)
// CoreDataで扱うTransformable型のattributesは、NSObjectではなくNSManagerObjectを継承している
public class Location: NSManagedObject, MKAnnotation {
    // MARK:- Photo Property
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoURL: URL {
        // assertは行儀の良いエラーハンドリング
        // crash箇所が特定しやすい利点がある
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
    
    // MARK:- MKAnnotation Property
    // MKAnnotationプロトコルに必須のプロパティ
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    // title, subtitleはオプション
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }

}
