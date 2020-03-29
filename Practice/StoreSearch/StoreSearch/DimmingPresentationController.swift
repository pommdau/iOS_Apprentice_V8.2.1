//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by HIROKI IKEUCHI on 2020/03/27.
//  Copyright © 2020 ikeh1024. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    // The presentationTransitionWillBegin() method is invoked when the new view controller is about to be shown on the screen.
    // containerView:=SearchViewControllerのトップに位置するView
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        
        // Animate background gradient view(fade in)
        dimmingView.alpha = 0
        if let corrdinator = presentedViewController.transitionCoordinator {
            // all of your animations should be done in a closure passed to animateAlongsideTransition to keep the transition smooth.
            corrdinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            // fade outのアニメーション
            coordinator.animate(alongsideTransition: {_ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
}
