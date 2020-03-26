//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by HIROKI IKEUCHI on 2020/03/26.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, response, error in
            if error == nil,
                let url   = url,
                let data  = try? Data(contentsOf: url),
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        })
        downloadTask.resume()  // 通信開始
        return downloadTask
    }
}
