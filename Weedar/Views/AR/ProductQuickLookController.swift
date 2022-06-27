//
//  ProductQuickLookController.swift
//  Weelar
//
//  Created by Bohdan Koshyrets on 9/28/21.
//

import UIKit
import QuickLook
import ARKit
import SwiftUI
import RealityKit

struct QuickLookView: View {
    var product: ProductModel

    var body: some View {
        ZStack {
            QuickLookViewContent(product: product)
                .zIndex(10)
        }
    }
}
    
struct QuickLookViewContent: UIViewRepresentable {
    typealias UIViewType = ARView
    
    var product: ProductModel

    func makeUIView(context: Context) -> ARView {
        let view = ARView()
        #if !targetEnvironment(simulator)
            let session = view.session
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            session.run(config)
            
            view.renderOptions.insert(.disableMotionBlur)
            
            context.coordinator.view = view
            session.delegate = context.coordinator
        #endif
        #if !targetEnvironment(simulator)
            let anchor = AnchorEntity(plane: .horizontal)
            view.scene.addAnchor(anchor)
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    class Coordinator: NSObject, ARSessionDelegate, ARCoachingOverlayViewDelegate {
        weak var view: ARView?
        var manager =  ProductManager(items: ARModelsManager.shared.itemNamesDemo, scale: 3.0, radius: 1.0)
        var product: ProductModel
        var isModelBeganLoading: Bool = false

        init(product: ProductModel) {
            self.product = product
            
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            print("trigerred didAdd anchors: ")
            guard let view = self.view else { return }
//            view.backgroundColor = UIColor.blue
            #if !targetEnvironment(simulator)
            if !isModelBeganLoading {
                let anchor = AnchorEntity(plane: .horizontal)
                
                manager.loadModel(product, for: anchor) { model in
                    view.installGestures(.all, for: model)
                }
                
                view.scene.addAnchor(anchor)
                
                isModelBeganLoading = true
            }
            #endif
        }
        
        func addCoaching(in frame: CGRect) {
            let coachingOverlay = ARCoachingOverlayView(frame: frame)
            coachingOverlay.delegate = view as? ARCoachingOverlayViewDelegate
            
            #if !targetEnvironment(simulator)
                coachingOverlay.session = view?.session
            #endif

            coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            coachingOverlay.goal = .horizontalPlane
            view?.addSubview(coachingOverlay)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(product: product)
    }
}
