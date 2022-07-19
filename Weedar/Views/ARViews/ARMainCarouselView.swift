//
//  ARMainCarouselView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.04.2022.
//

import ARKit
import SwiftUI
import RealityKit
import FocusEntity
 
struct ARMainCarouselView: View {
    var body: some View {
        ZStack{
            ARMainCarouselContainer()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ARMainCarouselContainer: UIViewRepresentable {
  
    func makeUIView(context: Context) -> ARView   {
        let view = ARView(frame: .zero)
        
        // Start AR session
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)
        
        // Set debug options
//        #if DEBUG
//        view.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
//        #endif
        
        
        // Handle ARSession events via delegate
        context.coordinator.view = view
        session.delegate = context.coordinator
        
        // Handle taps
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )
        )
        
        return view
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    
    func makeCoordinator() -> ARCarouselCoordinator {
        ARCarouselCoordinator()
   }
}

class ARCarouselCoordinator: NSObject, ARSessionDelegate {
    weak var view: ARView?
    var focusEntity: FocusEntity?

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let view = self.view else { return }
        
        debugPrint("Anchors added to the scene: ", anchors)
        self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
    }
    
    @objc func handleTap() {
        guard let view = self.view else { return }

        // Create a new anchor to add content to
        let anchor = AnchorEntity()
        view.scene.anchors.append(anchor)

        // Add a Box entity with a blue material
        let box = MeshResource.generateBox(size: 0.5, cornerRadius: 0.05)
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let diceEntity = ModelEntity(mesh: box, materials: [material])
        diceEntity.position = [0, -1, -4]

        anchor.addChild(diceEntity)
    }
}
