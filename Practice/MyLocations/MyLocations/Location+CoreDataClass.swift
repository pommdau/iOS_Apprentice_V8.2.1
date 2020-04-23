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

// (Location)はName mangling
// SwfitとObjective-Cが混ざっているプロジェクトの場合、コンパイルでうまくいかなくなる可能性がある
// Objective-C側にSwiftでLocationクラスがあるよ、と伝えている感じかな
@objc(Location)
// CoreDataで扱うTransformable型のattributesは、NSObjectではなくNSManagerObjectを継承している
public class Location: NSManagedObject {

}
