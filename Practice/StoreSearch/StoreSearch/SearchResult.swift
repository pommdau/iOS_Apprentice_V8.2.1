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
    var kind: String? = ""
    var artistName: String? = ""  // 返ってくるJSONデータは必ずしもデータを含まないのでオプショナル型にする
    var trackName: String? = ""
    
    var name: String {
        return trackName ?? ""
    }
    
    var description: String {
        return "Kind: \(kind ?? "None")  Name: \(name), Artist Name: \(artistName ?? "None")"
    }
    var trackPrice: Double? = 0.0
    var currency = ""
    var artworkUrl60 = ""
    var artworkUrl100 = ""
    var trackViewUrl: String? = ""
    var primaryGenreName = ""
}
