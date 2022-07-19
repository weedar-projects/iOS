//
//  ARGameViewContainer.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.07.2022.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

private let anchorNamePrefix = "model-"

struct ARGameViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    
        
    func makeUIView(context: Context) -> CustomGameARView {
        
        let arView = CustomGameARView(frame: .zero, sessionSettings: sessionSettings, modelDeletionManager: modelDeletionManager)
        
        arView.session.delegate = context.coordinator
                
        // Subscribe to Scene Events - https://developer.apple.com/documentation/realitykit/sceneevents/update
        // NOTE: This is easier than dealing with a ARSessionDelegate method
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { event in
            self.updateScene(for: arView)
            self.updatePersistenceAvailability(for: arView)
            self.handlePersistence(for: arView)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomGameARView, context: Context) {}
    
    private func updateScene(for arView: CustomGameARView) {
        
        // Only display focusEntity when in "placement mode"
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        // Add model(s) to scene if confirmed for placement
        if let modelAnchor = self.placementSettings.modelsConfirmedForPlacement.popLast(), let modelEntity = modelAnchor.model.modelEntity {
            
            if let anchor = modelAnchor.anchor {
                // Anchor is being loaded from persistent scene
                self.place(modelEntity, for: anchor, in: arView)
            } else if let transform = getTransformForPlacement(in: arView) {
                // Anchor needs to be created for placement
                let anchorName = anchorNamePrefix + modelAnchor.model.name
                let anchor = ARAnchor(name: anchorName, transform: transform)
                
                self.place(modelEntity, for: anchor, in: arView)
                
                arView.session.add(anchor: anchor)
                
                self.placementSettings.recentlyPlaced.append(modelAnchor.model)
            }
        }
    }
    
    private func place(_ modelEntity: ModelEntity, for anchor: ARAnchor, in arView: ARView) {
        let modelEntityClone = modelEntity.clone(recursive: true) // Cloning creates an identical copy, which references the same model
        
        // Enable translation and rotation gestures
        modelEntityClone.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: modelEntityClone)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(modelEntityClone)
        
        anchorEntity.anchoring = AnchoringComponent(anchor)
        
        arView.scene.addAnchor(anchorEntity)
        
        self.sceneManager.anchorEntities.append(anchorEntity)
                
        print("Added modelEntity to scene.")
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .any) else { return nil }
        guard let raycastResult = arView.session.raycast(query).first else { return nil }
        
        return raycastResult.worldTransform
    }
}


// Reference: https://developer.apple.com/documentation/arkit/data_management/saving_and_loading_world_data
extension ARGameViewContainer {
    private func updatePersistenceAvailability(for arView: ARView) {
        guard let currentFrame = arView.session.currentFrame else {
            print("ARFrame not available.")
            return
        }
        
        // Allow user to save AR content when mapping status is good and at least one model has been placed in the scene.
        
        switch currentFrame.worldMappingStatus {
        case .mapped, .extending:
            self.sceneManager.isPersistenceAvailable = !self.sceneManager.anchorEntities.isEmpty
        default:
            self.sceneManager.isPersistenceAvailable = false
        }
    }
    
    private func handlePersistence(for arView: CustomGameARView) {
        if self.sceneManager.shouldSaveSceneToFilesystem {
            
            ScenePersistenceHelper.saveScene(for: arView, at: self.sceneManager.persistenceUrl)
            
            self.sceneManager.shouldSaveSceneToFilesystem = false
            
        } else if self.sceneManager.shouldLoadSceneFromFilesystem {
            
            guard let scenePersistenceData = self.sceneManager.scenePersistenceData else {
                print("Unable to retrieve scenePersistenceData. Canceled loadScene operation.")
                return
            }
                        
            self.modelsViewModel.clearModelEntitiesFromMemory()
            
            self.sceneManager.anchorEntities.removeAll(keepingCapacity: true)
                        
            ScenePersistenceHelper.loadScene(for: arView, with: scenePersistenceData)
                        
            self.sceneManager.shouldLoadSceneFromFilesystem = false
            
        }
    }
}

// MARK: - ARSessionDelegate + Coordinator
// Reference: https://www.hackingwithswift.com/books/ios-swiftui/using-coordinators-to-manage-swiftui-view-controllers
extension ARGameViewContainer {
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARGameViewContainer

        init(_ parent: ARGameViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let anchorName = anchor.name, anchorName.hasPrefix(anchorNamePrefix) {
                    let modelName = anchorName.dropFirst(anchorNamePrefix.count)
                    
                    print("ARSession: didAdd anchor for modelName: \(modelName).")
                    
                    guard let model = self.parent.modelsViewModel.models.first(where: { $0.name == modelName }) else {
                        print("Unable to retrieve model from modelsViewModel.")
                        return
                    }
                                        
                    // IMPORTANT: This should only run when loading anchors from a persisted scene. If the user places a model, the modelAnchor should be already appended to modelsConfirmedForPlacement.
                    if model.modelEntity == nil {
                        model.asyncLoadModelEntity { completed, error in
                            print("ARSession: loaded modelEntity for anchor - \(modelName)")
                            if completed {
                                let modelAnchor = ModelAnchor(model: model, anchor: anchor)
                                self.parent.placementSettings.modelsConfirmedForPlacement.append(modelAnchor)
                                print("Adding modelAnchor with name: \(model.name)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
