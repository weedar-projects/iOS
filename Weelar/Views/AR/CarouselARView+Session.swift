//
//  CarouselARView+Session.swift
//  Weelar
//
//  Created by Bohdan Koshyrets on 11/19/21.
//

import RealityKit
import ARKit

extension CarouselARView: ARSessionDelegate {
  
    fileprivate func monitorCarouselContent() {
        for productAnchor in productsAnchor.children {
            if !paused {
                manager.monitorRotation(forAnchor: productAnchor as! ModelEntity)
            }
        }
    }
    
    fileprivate func monitorHighlightedProduct() {
        let location: CGPoint = self.center
        
        if let object = self.entity(at: location) {
            updateHighlightedProduct(productName: object as! ModelEntity)
            
            if tutorialStage == .waitToStart {
                tutorialStage = .show
            }

        }
    }
    
    fileprivate func monitorOverscroll() {
        #if !targetEnvironment(simulator)
            if gestureHandler?.panGesture?.state == .possible {
                if let productAnchor = productsAnchor.children.first {
                    let segmentCenter = manager.segmentCenter(for: productAnchor as! ModelEntity)
                    updateOverscroll(lastSpeed: lastScrollSpeed, segmentCenter: segmentCenter)
                }
            }
        #endif
    }

    fileprivate func updateCursorIfInDetailedView() {
        switch state {
        case .overview:
            break
            
        case .detail(items: let entities):
            #if !targetEnvironment(simulator)
            for entity in entities {
                updateCursorPosition(for: entity)
            }
            
            if entities.count > 1 {
                
                var entitiesTemp = entities
                let entityToBeRemoved = entitiesTemp.removeFirst()
                entityToBeRemoved.removeFromParent()
                
                state = .detail(items: entitiesTemp)
            }
            #endif
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
//        print("Product anchor: \(productsAnchor.transform)")
//        print("")
        
        if shouldDoPerFrameUpdates {
            monitorCarouselContent()
            monitorHighlightedProduct()
            monitorOverscroll()
            updateCursorIfInDetailedView()
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print(#function)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print(#function)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print(#function)
        print("quantity: \(anchors.count)")
    }
        
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        print(#function)
    }
}
