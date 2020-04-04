//
//  Search.swift
//  StoreSearch
//
//  Created by HIROKI IKEUCHI on 2020/04/03.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import Foundation

class Search {
    var searchResults: [SearchResult] = []
    var hasSearched = false
    var isLoading = false
    
    private var dataTask: URLSessionDataTask? = nil
    
    func performSearch(for text: String, category: Int) {
        if !text.isEmpty {
            isLoading     = true
            hasSearched   = true
            searchResults = []

            let url      = iTunesURL(searchText: text, category: category)
            let session  = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                // Was the search cancelled
                if let error = error as NSError?, error.code == -999 {
                    return  // Search was cancelled
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 {
                    if let data = data {
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort(by: <)
                        
                        print("Success")
                        self.isLoading = false
                        return
                    }
                }
                print("Failure! \(response!)")
                self.hasSearched = false
                self.isLoading = false
            })
            dataTask?.resume()  // 通信開始
        }
    }
    
    private func iTunesURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""  // All:0
        }
        
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
