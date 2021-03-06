//
//  ViewController.swift
//  StoreSearch
//
//  Created by Hiroki Ikeuchi on 2020/03/15.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell      = "LoadingCell"
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var search = Search()
    var landscapeVC : LandscapeViewController?
    weak var splitViewDetail: DetailViewController?  // for iPad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Search", comment: "split view master button")  // iPadのときNavigationBarに表示するラベルの設定
        
        // 64ポイントのマージンを上部に取る設定。20:Status Bar, 44:SearchBar, 44:Segmented Control
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0 )
        
        // identifierを「TableView.CellIdentifiers.searchResultCell」で呼び出したときに、指定のxibから読み込む設定
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        // iPad以外のときにキーボードを表示する
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
       
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        let normalTextAttributes   = [NSAttributedString.Key.foregroundColor: segmentColor]
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.selectedSegmentTintColor = segmentColor
        segmentedControl.setTitleTextAttributes(normalTextAttributes,   for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        let rect = UIScreen.main.bounds
        if (rect.width == 736 && rect.height == 414) ||  // portrait (iPhone Plus)
            (rect.width == 414 && rect.height == 736) {  // landscape(iPhone Plus)
            // iPhone Plusの場合
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)  // Detail pop-upがあれば非表示にする
            }
        } else if UIDevice.current.userInterfaceIdiom != .pad {
            switch newCollection.verticalSizeClass {
            case .compact:  // iPhone Landscape, iPhone 6 plus Landscape
                showLandscape(with: coordinator)
            case .regular, .unspecified:  // iPhone Portrait, iPad Portrait/Landscape
                hideLandscape(with: coordinator)
            @unknown default:
                fatalError()
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops...", comment: "Network error Alert title"),
                                      message: NSLocalizedString("There was an error accessing the iTunes Store. Please try again.", comment: "Network error message"),
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button title"), style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Heloper Methods
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }  // すでに表示されているならば何もしない
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC {  // SearchViewControllerにLandscapeVIewControllerをChildとして埋め込む
            controller.search = search  // viewDidLoad()を呼ぶためのトリガとなるので、controller.viewにアクセスする前に呼ぶ必要がある
            
            controller.view.frame = view.bounds  // SearchViewControllerの大きさにする
            controller.view.alpha = 0  // for crossfade
            
            view.addSubview(controller.view)     // subViewに追加
            addChild(controller)                 // SearchViewControllerにLandscapeVIewControllerが画面の一部であることを伝える
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                
                if self.presentedViewController != nil {  // DetailViewControllerが表示されているならばcloseする
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.didMove(toParent: self)  // 新しいViewに親のViewを持つことを伝える
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
                if self.presentedViewController != nil {    // DetailViewControllerが表示されているならばcloseする
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
            
        }
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath            = sender as! IndexPath
                let searchResult         = list[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.ispopUp      = true
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(for: searchBar.text!,
                                 category: category,
                                 completion: { success in
                                    if !success {
                                        self.showNetworkError()
                                    }
                                    self.tableView.reloadData()
                                    self.landscapeVC?.searchResultsReceived()  // landscapeではない場合は何もしない。Optional chaningはif let~と同じだが簡潔に書ける。
            })
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    // ViewControllerがUISplitViewControllerの中にある場合、built in propertyとして「splitViewController」を持つ
    private func hideMasterPane() {
        UIView.animate(withDuration: 0.25,
                       animations: {
                        self.splitViewController!.preferredDisplayMode = .primaryHidden
        }, completion: { _ in
            self.splitViewController!.preferredDisplayMode = .automatic
        })
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
            
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // SearchViewControllerはiPadでもSplitViewのmaster側なので.compactになる
        // よってrootViewControllerをここでは取っている
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {  // iPhoneのとき
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {  // iPadのとき
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
                
                // .allVisibleはlandscapeのときのみ有効
                // -> landscape出ない場合に行が選択されたらmaster paneを隠す
                if splitViewController!.displayMode != .allVisible {
                    hideMasterPane()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
}
