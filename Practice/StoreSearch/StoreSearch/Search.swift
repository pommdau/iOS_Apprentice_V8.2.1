//
//  Search.swift
//  StoreSearch
//
//  Created by HIROKI IKEUCHI on 2020/04/03.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import Foundation

class Search {
    enum Category: Int {
        case all      = 0
        case music    = 1
        case software = 2
        case ebooks   = 3
        
        var type: String {  // self = enumeration object
            switch self {
            case .all:      return ""
            case .music:    return "musicTrack"
            case .software: return "software"
            case .ebooks:   return "ebook"
            }
        }
    }
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])  // これ以外のStateでは検索結果を持たない
    }
    
    private var dataTask: URLSessionDataTask? = nil
    typealias SearchComplete = (Bool) -> Void   // 引数にBool型1つをとり、返り値がVoidの型をSearchCompleteと定義する
    private(set) var state: State = .notSearchedYet  // Read only
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            state = .loading

            let url      = iTunesURL(searchText: text, category: category)
            let session  = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                
                var success = false
                var newState = State.notSearchedYet  // 直接プロパティを変更せずに、mainスレッドで変更するのが安全
                
                // Was the search cancelled
                if let error = error as NSError?, error.code == -999 {
                    return  // Search was cancelled
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let data = data {
                    var searchResults = self.parse(data: data)
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort(by: <)
                        newState = .results(searchResults)
                    }
                    success = true
                }
                DispatchQueue.main.async {
                    self.state = newState
                    completion(success)
                }
            })
            dataTask?.resume()  // 通信開始
        }
    }
    
    private func iTunesURL(searchText: String, category: Category) -> URL {
        let kind = category.type
        
        // スペースなどをパーセントエンコーディングする
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?" +
        "term=\(encodedText)&&limit=200&entity=\(kind)"
        
        let url = URL(string: urlString)
        return url!
    }
    
    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
}
