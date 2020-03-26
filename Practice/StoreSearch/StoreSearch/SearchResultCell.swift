//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Hiroki Ikeuchi on 2020/03/15.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    var downloadTask: URLSessionDownloadTask?  // 1つのセルに必要なTaskは1つだけ
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 画像をダウンロードするまえにスクロールしまった場合に、ダウンロードを中断する
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    // MARK:- Public Methods
    func configure(for result: SearchResult){
        nameLabel.text = result.name
        
        if result.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = String(format: "%@(%@)", result.artist, result.type)
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
}
