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
    
    var name: String {
        return trackName ?? ""
    }
    
    var description: String {
        return "Kind: \(kind ?? "None")  Name: \(name), Artist Name: \(artistName ?? "None")"
    }
    
    var trackName: String? = ""
    
    var trackPrice: Double? = 0.0
    var currency = ""
    
    var imageSmall = ""
    var imageLarge = ""
    var storeURL: String? = ""
    var genre = ""
    
    // JSONのキー名とプロパティ名が異なるのでCodingKeysを使用する
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case storeURL = "trackViewUrl"
        case genre = "primaryGenreName"
        case kind, artistName, trackName
        case trackPrice, currency
    }
}
