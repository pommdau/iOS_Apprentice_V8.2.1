//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by Hiroki Ikeuchi on 2020/03/29.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    // アニメーションにかかる時間
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    // 実行するアニメーション
    // transitionContext parameter := This gives you a reference to a new view controller
    // and lets you know how big it should be.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
           let toView           = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toViewController)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)  // 70%:アニメーション開始時の大きさ
            
            // 実際にアニメーションを開始する
            // animateKeyframes:=段階に分けてアニメーションできる
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                    delay: 0,
                                    options: .calculationModeCubic,
                                    animations: {
                                        UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                           relativeDuration: 0.334,
                                                           animations: {
                                                            toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)  // 120%
                                        })
                                        UIView.addKeyframe(withRelativeStartTime: 0.334,
                                                           relativeDuration: 0.333,
                                                           animations: {
                                                            toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)  // 90%
                                        })
                                        UIView.addKeyframe(withRelativeStartTime: 0.666,
                                                           relativeDuration: 0.333,
                                                           animations: {
                                                            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)  // 100%
                                        })
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
