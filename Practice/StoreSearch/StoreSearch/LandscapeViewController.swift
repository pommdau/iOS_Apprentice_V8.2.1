//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by HIROKI IKEUCHI on 2020/03/30.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var search: Search!
    private var firstTime = true
    private var downloads = [URLSessionDownloadTask]()  // ダウンロードを途中でキャンセルするためのプロパティ
    
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        if let url = URL(string: searchResult.imageSmall) {
            let task = URLSession.shared.downloadTask(with: url) {
                // 以下はサブスレッドで呼ばれる
                // [weak button]: 途中でキャンセルすることがあるのでweakでキャプチャーしている
                // よって開放されnilになることがあるので、if letでreturnして安全に処理している
                // またdeinitでもダウンロードがあればキャンセルしている。これは無駄な処理をしないため。
                [weak button] url, response, error in
                
                if error == nil,
                    let url = url,
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            task.resume()  // 通信開始
            downloads.append(task)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove constraints from main view
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        // Remove constraints for page control
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        // Remove constraints for scroll view
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        pageControl.numberOfPages = 0  // 0で非表示となる
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame  // safe areaいっぱいに広げる
        pageControl.frame = CGRect(x: safeFrame.origin.x,
                                   y: safeFrame.size.height - pageControl.frame.size.height,
                                   width: safeFrame.size.width,
                                   height: pageControl.frame.size.height)
        
        // viewDidLoadが呼ばれた時点ではまだスクリーンに読み込まれていないので、画面の大きさが取得できない
        // なのでviewWillLayoutSubviewsでリサイズが終わった後に呼んでいる
        // またScreenからこのViewが削除されるときもviewWillLayoutSubviewsは呼ばれるので、
        // 一回だけ呼ばれるようにfirstTime変数を使う
        if firstTime {
            firstTime = false
            
            switch search.state {
            case .notSearchedYet:
                break
            case .loading:
                showSpinner()
                break
            case .noResults:
                showNothingFoundLabel()
                break
            case .results(let list):
                tileButtons(list)
            }
        }
    }
    
    deinit {
        print("deinit \(self)")
        // 画像をダウンロードしているならばキャンセルする
        for task in downloads {
            task.cancel()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let searchResult = list[(sender as! UIButton).tag - 2000]
                detailViewController.searchResult = searchResult
                detailViewController.ispopUp      = true
            }
        }
    }

    // MARK:- Private Methods
    private func tileButtons(_ searchResults: [SearchResult]) {
        // デフォルトは4-inch deviceとする
        var columnsPerPage      = 6
        var rowsPerPage         = 3
        var itemWidth : CGFloat = 94
        var itemHeight: CGFloat = 88
        var marginX: CGFloat    = 2  // 568 % 6columns = 4が余るのでマージンはページの両端で2
        var marginY: CGFloat    = 20
        
        let viewWidth = scrollView.bounds.size.width
        
        switch viewWidth {
        case 568:
            // 4-inch device
            break
            
        case 667:
        // 4.7-inch device
            columnsPerPage  = 7   //4-inchに比べて横に広いので、columnを1つ増やす
            itemWidth       = 95
            itemHeight      = 98  // 少し大きい98point
            marginX         = 1   // 667 % 3 = 1
            marginY         = 29
            
        case 736:
            // 5.5-inch device
            columnsPerPage  = 8
            rowsPerPage     = 4
            itemWidth       = 92
            marginX         = 0
            
        case 724:
            // iPhone X
            columnsPerPage  = 8
            rowsPerPage     = 3  // 画面は大きいがsafe areaがあるのでrowは3つ
            itemWidth       = 90
            itemHeight      = 98
            marginX         = 2
            marginY         = 29
            
        default:
            break
        }
        
        // Button size
        let buttonWidth : CGFloat = 82
        let buttonHeihgt: CGFloat = 82
        let paddingHorz = (itemWidth  - buttonWidth )/2
        let paddingVert = (itemHeight - buttonHeihgt)/2
        
        // Add the buttons
        var row    = 0
        var column = 0
        var x      = marginX
        
        for (index, result) in searchResults.enumerated() {
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row)*itemHeight + paddingVert,
                                  width: buttonWidth,
                                  height: buttonHeihgt)
            button.tag = 2000 + index  // tag=0はViewに使われているので2000から始める。また1000はspinnerですでに使われている。
            button.addTarget(self, action: #selector(buttonPressed),
                             for: .touchUpInside)
            
            downloadImage(for:result, andPlaceOn: button)
            scrollView.addSubview(button)

            row += 1
            if row == rowsPerPage {  // column1列の配置が終わったら次のcolumnへ移る
                row = 0
                x += itemWidth
                column += 1
                
                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
             }
        }
        
        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = (searchResults.count - 1) / buttonsPerPage + 1  // 結果が切り捨てのIntなので+1をする
        scrollView.contentSize = CGSize(width: viewWidth * CGFloat(numPages),
                                        height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage   = 0
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .large)
        // 0.5はスピーナーの左上の座標を小数点としないため
        // spinnerの幅と高さは37Point
        // 例えば中心座標が(284,160)とすると、18.5を引いた、スピナーの左上の座標は(265.5,141.5)となってしまう
        spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5,
                                 y: scrollView.bounds.midY + 0.5)
        spinner.tag = 1000  // 後で削除するためにタグをつけておく
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()  // indicatorは強参照されていないのでオプショナルチェインが必要
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = NSLocalizedString("Nothing Found", comment: "Search results: Nothing Found")
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        
        label.sizeToFit()
        
        var rect = label.frame
        rect.size.width  = ceil(rect.size.width/2)  * 2  // make even
        rect.size.height = ceil(rect.size.height/2) * 2  // make even
        label.frame = rect
        
        label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)  // 画面サイズはevenなのでここは補正しないでOK
        view.addSubview(label)
    }
    
    // MARK:- Public Methods
    func searchResultsReceived() {
        hideSpinner()
        
        switch search.state {
        case .notSearchedYet, .loading:
            break
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(list)
        }
    }
    
    // MARK:- Actions
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
                        // UIPageControlをタップしたときにページを遷移する
                        self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                                                           y: 0)
        }, completion: nil)
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)  // 現在表示しているページ。半分以上ページをスクロールした時点でpageの表示を更新する
        
        pageControl.currentPage = page
    }
}
