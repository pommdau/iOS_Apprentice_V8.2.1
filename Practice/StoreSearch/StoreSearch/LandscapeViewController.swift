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
    
    var searchResults = [SearchResult]()
    private var firstTime = true
    
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
            tileButtons(searchResults)
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

    // MARK:- Private Methods
    private func tileButtons(_ searchResults: [SearchResult]) {
        var columnsPerPage      = 6
        var rowsPerPage         = 3
        var itemWidth: CGFloat  = 94
        var itemHeight: CGFloat = 88
        var marginX: CGFloat    = 2  // 568 % 6columns = 4が余るのでマージンは両端で2
        var marginY: CGFloat    = 20
        
        let viewWidth = scrollView.bounds.size.width
        
        switch viewWidth {
        case 568:
            // 4-inch device
            break
            
        case 667:
        // 4.7-inch device
            columnsPerPage  = 7
            itemWidth       = 95
            itemHeight      = 98
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
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.white
            button.setTitle("\(index)", for: .normal)
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row)*itemHeight + paddingVert,
                                  width: buttonWidth,
                                  height: buttonHeihgt)
            scrollView.addSubview(button)

            row += 1
            if row == rowsPerPage {  // row1列の配置が終わったら次のcolumnへ移る
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
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth,
                                        height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
    }
}
