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
// 返ってくるJSONデータは必ずしもデータを含まないのでオプショナル型にする
//
// [Audiobooks]
// 1. kind: This value is not present at all.
// 2. trackName: Instead of "trackName", you get "collectionName".
// 3. trackviewUrl: Instead of this value, you have "collectionViewUrl" — which provides the iTunes link to the item.
// 4. trackPrice: Instead of "trackPrice", you get "collectionPrice".
//
// [Others]
// 1. Software and e-book items do not have "trackPrice" key, instead they have a "price" key.
// 2. E-books don’t have a “primaryGenreName” key — they have an array of genres.

class SearchResult: Codable, CustomStringConvertible {

    var kind : String? = ""  // Audiobooksの場合はnil
    var type:String {   // 表示する種類をユーザフレンドリにする
        let kind = self.kind ?? "audiobook"
        switch kind {
        case "album"        : return "Album"
        case "audiobook"    : return "Audio Book"
        case "book"         : return "Book"
        case "ebook"        : return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video"  : return "Music Video"
        case "podcast"      : return "Podcast"
        case "software"     : return "App"
        case "song"         : return "Song"
        case "tv-episode"   : return "TV Episode"
        default             : break
        }
        return "Unknown"
    }
    
    var artistName: String? = ""
    var artist    : String {
        return artistName ?? ""
    }
    
    var currency   = ""
    
    var trackName     : String? = ""
    var collectionName: String?  // for audiobooks
    var name          : String {
        return trackName ?? collectionName ?? ""
    }
        
    var imageSmall = ""
    var imageLarge = ""

    var trackViewUrl     : String?
    var collectionViewUrl: String?  // for audiobooks
    var storeURL         : String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var trackPrice     : Double? = 0.0
    var collectionPrice: Double?  // for audiobooks
    var itemPrice      : Double?  // for software and e-book
    var price          : Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var itemGenre: String?
    var bookGenre: [String]?  // for e-books
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
        case itemGenre  = "primaryGenreName"
        case bookGenre  = "genres"
        case itemPrice  = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
    
    var description: String {
        return "Kind: \(kind ?? "None")  Name: \(name), Artist Name: \(artistName ?? "None")"
    }
}
