//
//  GradientView.swift
//  StoreSearch
//
//  Created by Hiroki Ikeuchi on 2020/03/29.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        // SuperViewの大きさに合わせる設定。
        // AutoLayoutの前身の制約。協力ではないが簡単。
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    // 呼ばれないがサブクラスで実装が必須なinitメソッド
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func draw(_ rect: CGRect) {
        // The first color (0, 0, 0, 0.3) is a black color that is mostly transparent.
        // The second color (0, 0, 0, 0.7) is also black but much less transparent and sits at location 1
        let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]
        let locations : [CGFloat] = [ 0, 1 ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient   = CGGradient(colorSpace: colorSpace,
                                    colorComponents: components,
                                    locations: locations,
                                    count: 2)
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y : y)
        let radius = max(x, y)

        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!,
                                    startCenter: centerPoint,
                                    startRadius: 0,
                                    endCenter: centerPoint,
                                    endRadius: radius,
                                    options: .drawsAfterEndLocation)
    }
    
}
