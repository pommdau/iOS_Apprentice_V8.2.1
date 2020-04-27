//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/27.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit

extension UIImage {
    // そのまま大きいサイズの画像を使用すると、ぼやけた感じになり、またメモリの無駄遣いとなってしまう
    func resized(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)  // 返す画像はaspect fitである
        let newSize = CGSize(width: size.width * ratio,
                             height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
