//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by HIROKI IKEUCHI on 2020/03/27.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var popupView        : UIView!
    @IBOutlet weak var artworkImageView : UIImageView!
    @IBOutlet weak var nameLabel        : UILabel!
    @IBOutlet weak var artistNameLabel  : UILabel!
    @IBOutlet weak var kindLabel        : UILabel!              
    @IBOutlet weak var genreLabel       : UILabel!
    @IBOutlet weak var priceButton      : UIButton!
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?  // 詳細画像をダウンロードするためのもの
    
    enum AnimationStyle {
        case slide
        case fade
    }
    var dismissStyle = AnimationStyle.fade
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 画面遷移をカスタムにする設定
        modalPresentationStyle = .custom
        transitioningDelegate  = self
    }
    
    deinit {
        // 詳細画像のダウンロードをキャンセルする
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        view.backgroundColor = UIColor.clear
        popupView.layer.cornerRadius = 10
        
        // このViewController内でGestureRecognizerが機能させる設定
        //
        // popupView内は以下のメソッドで無効になっている。
        // gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if searchResult != nil {
            updateUI()  // just in case the developer forgets to fill in searchResult on the segue.
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
    
    
    // MARK:- Actions
    @IBAction func close() {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:],
                                      completionHandler: nil)
        }
    }
    
    
    // MARK:- Helper Methods
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artist.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Artist name: Unknown")
        } else {
            artistNameLabel.text = searchResult.artist
        }
        kindLabel.text  = searchResult.type
        genreLabel.text = searchResult.genre
        
        
        // Show price
        let formatter = NumberFormatter()
        formatter.numberStyle  = .currency
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        if searchResult.price == 0 {
            priceText = NSLocalizedString("Free", comment: "Price text: Free")
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        // Get image
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    // このViewへの遷移に関して、DimmingPresentationControllerを通常のPresentationControllerの代わりに使う設定
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented,
                                             presenting: presenting)
    }
    
    // 遷移時にアニメーションを使用する設定
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
        
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {

    // 自分のビュー以外、つまりpopupViewの外側を選択したときにtouchを受け取る設定
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
