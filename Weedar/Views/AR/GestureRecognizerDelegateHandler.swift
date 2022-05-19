//
//  GestureRecognizerDelegateHandler.swift
//  Weelar
//
//  Created by Galym Anuarbek on 24.08.2021.
//

import UIKit

class GestureRecognizerDelegateHandler: NSObject, UIGestureRecognizerDelegate {
    
    var tapGesture: UITapGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?
    
    var animationOpenGesture: UISwipeGestureRecognizer?
    var animationCloseGesture: UISwipeGestureRecognizer?
    
    var zoomGesture: UIPinchGestureRecognizer?
    
    init(tapGesture: UITapGestureRecognizer,
         animationOpenGesture: UISwipeGestureRecognizer,
         animationCloseGesture: UISwipeGestureRecognizer,
         panGesture: UIPanGestureRecognizer,
         zoomGesture: UIPinchGestureRecognizer) {
       
        self.tapGesture = tapGesture
        self.animationOpenGesture = animationOpenGesture
        self.animationCloseGesture = animationCloseGesture
        self.panGesture = panGesture
        self.zoomGesture = zoomGesture
        
        super.init()
        self.tapGesture?.delegate = self
        self.animationOpenGesture?.delegate = self
        self.animationCloseGesture?.delegate = self
        self.panGesture?.delegate = self
        self.zoomGesture?.delegate = self
    }
    
    func configureGestures(for state: ARViewState, view: CarouselARView) {
        switch state {
        case .overview:
            view.removeGestureRecognizer(animationOpenGesture!)
            view.removeGestureRecognizer(animationCloseGesture!)
            view.removeGestureRecognizer(zoomGesture!)
        case .detail(items: _):
            view.addGestureRecognizer(animationOpenGesture!)
            view.addGestureRecognizer(animationCloseGesture!)
            view.addGestureRecognizer(zoomGesture!)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture && (otherGestureRecognizer == animationCloseGesture || otherGestureRecognizer == animationOpenGesture) {
            return true
        }
        
        return false
    }
}
