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

class SearchResult: Codable {
    var artistName: String? = ""  // 返ってくるJSONデータは必ずしもデータを含まないのでオプショナル型にする
    var trackName: String? = ""
    
    var name: String {
        return trackName ?? ""
    }
}
