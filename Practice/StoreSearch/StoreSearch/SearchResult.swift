//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Hiroki Ikeuchi on 2020/03/15.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

// CustomStringConvertible: the protocol allows objects to have a custom string describing the object, or its contents.
class SearchResult: Codable, CustomStringConvertible {
    var artistName: String? = ""  // 返ってくるJSONデータは必ずしもデータを含まないのでオプショナル型にする
    var trackName: String? = ""
    
    var name: String {
        return trackName ?? ""
    }
    
    var description: String {
        return "Name: \(name), Artist Name: \(artistName ?? "None")"
    }
}
