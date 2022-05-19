//
//  CaroucelARView+Coaching.swift
//  CaroucelARView+Coaching
//
//  Created by Bohdan Koshyrets on 8/12/21.
//

import ARKit

extension CarouselARView: ARCoachingOverlayViewDelegate {
    func addCoaching(in frame: CGRect) {
        let screenFrame = UIScreen.main.bounds
        coachingOverlay = ARCoachingOverlayView(frame: screenFrame)
        if let overlay = coachingOverlay {
            
            overlay.delegate = self
            
            #if !targetEnvironment(simulator)
                overlay.session = self.session
            #endif
            
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            overlay.goal = .horizontalPlane
            self.addSubview(overlay)
        }
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        anchor?.isEnabled = false
        shouldShowDescriptionCard = false
        highlightedProduct = nil
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        anchor?.isEnabled = true
        shouldShowDescriptionCard = true
        
//        updateAngles()
    }
    
//    private func updateAngles() {
//        angle = session.currentFrame?.camera.eulerAngles.y
//        if let angle = angle {
//            
//            productsAnchor.transform.rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
//        }
//    }
}
