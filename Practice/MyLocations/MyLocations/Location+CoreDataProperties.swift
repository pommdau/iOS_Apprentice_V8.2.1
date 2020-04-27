//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/23.
//  Copyright © 2020 hikeuchi. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {
    // @nonobjc: Objective-Cで使用不可であることを示す
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
    
    // @NSManaged: オブジェクトはCoreData runtimeによって処理されるの意
    // e.g. 値をセットしたときにCoreDataによって保存される
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?
    // CoreDataがObjective-C frameworkなのでNSNumber型
    @NSManaged public var photoID: NSNumber?
}
