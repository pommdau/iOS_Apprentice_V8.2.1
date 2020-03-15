//
//  ViewController.swift
//  StoreSearch
//
//  Created by Hiroki Ikeuchi on 2020/03/15.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false  // 検索を既に行った状態かどうか
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 64ポイントのマージンを上部に取る設定。20:Status Bar, 44:SearchBar
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0 )
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        searchResults = []
        for i in 0...2 {
            if searchBar.text! != "Hoge" {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake Result %d for '%@'", i, searchBar.text!)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        hasSearched = true
        tableView.reloadData()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        if searchResults.count == 0 {  // 検索結果が0の場合
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }
        return cell
            
    }
}
