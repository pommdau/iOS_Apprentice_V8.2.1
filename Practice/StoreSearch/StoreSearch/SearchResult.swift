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
    var kind      : String? = ""
    var artistName: String? = ""  // 返ってくるJSONデータは必ずしもデータを含まないのでオプショナル型にする
    var currency   = ""
    
    var trackName     : String? = ""
    var collectionName: String?
    var name          : String {
        return trackName ?? collectionName ?? ""
    }
        
    var imageSmall = ""
    var imageLarge = ""

    var trackViewUrl     : String?
    var collectionViewUrl: String?
    var storeURL         : String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var trackPrice     : Double? = 0.0
    var collectionPrice: Double?
    var itemPrice      : Double?
    var price          : Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var itemGenre: String?
    var bookGenre: [String]?
    var genre    : String {
        if let genre = itemGenre {  // e-book以外
            return genre
        } else if let genres = bookGenre {  // e-book用
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    // JSONのキー名とプロパティ名が異なるのでCodingKeysを使用する
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
    
    var description: String {
        return "Kind: \(kind ?? "None")  Name: \(name), Artist Name: \(artistName ?? "None")"
    }
}
