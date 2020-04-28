//
//  String+AddText.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/27.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import Foundation

extension String {
    // mutating: varで宣言されたStringでのみ使われるメソッドの意
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
