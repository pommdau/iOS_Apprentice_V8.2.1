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
