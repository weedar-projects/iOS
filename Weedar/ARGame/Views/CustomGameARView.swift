//
//  CustomGameARView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.07.2022.
//

import RealityKit
import ARKit
import FocusEntity
import SwiftUI
import Combine

class CustomGameARView: ARView {
    var focusEntity: FocusEntity?
    var sessionSettings: SessionSettings
    var modelDeletionManager: ModelDeletionManager
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
    
        // Enable sceneReconstruction if the device has a LiDAR Scanner
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        return config
    }
        
    private var peopleOcclusionCancellable: AnyCancellable?
    private var objectOcclusionCancellable: AnyCancellable?
    private var lidarDebugCancellable: AnyCancellable?
    private var multiuserCancellable: AnyCancellable?
    
    // Reference: https://stackoverflow.com/q/62083835
    required init(frame frameRect: CGRect, sessionSettings: SessionSettings, modelDeletionManager: ModelDeletionManager) {
        self.sessionSettings = sessionSettings
        self.modelDeletionManager = modelDeletionManager

        super.init(frame: frameRect)
                
        self.focusEntity = FocusEntity(on: self, focus: .classic)
        
        self.configure()
        
        self.initializeSettings()
                
        self.setupSubscribers()
        
        self.enableObjectDeletion()
    }
    
    // Reference: https://stackoverflow.com/a/63779989
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented.")
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        session.run(defaultConfiguration, options: [])
    }
    
    private func initializeSettings() {
        self.updatePeopleOcclusion(isEnabled: sessionSettings.isPeopleOcclusionEnabled)
        self.updateObjectOcclusion(isEnabled: sessionSettings.isObjectOcclusionEnabled)
        self.updateLidarDebug(isEnabled: sessionSettings.isLidarDebugEnabled)
        self.updateMultiuser(isEnabled: sessionSettings.isMultiuserEnabled)
    }
    
    private func setupSubscribers() {
        self.peopleOcclusionCancellable = sessionSettings.$isPeopleOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updatePeopleOcclusion(isEnabled: isEnabled)
        }
        
        self.objectOcclusionCancellable = sessionSettings.$isObjectOcclusionEnabled.sink { [weak self] isEnabled in
            self?.updateObjectOcclusion(isEnabled: isEnabled)
        }
        
        self.lidarDebugCancellable = sessionSettings.$isLidarDebugEnabled.sink { [weak self] isEnabled in
            self?.updateLidarDebug(isEnabled: isEnabled)
        }
        
        self.multiuserCancellable = sessionSettings.$isMultiuserEnabled.sink { [weak self] isEnabled in
            self?.updateMultiuser(isEnabled: isEnabled)
        }
    }
    
    // Reference: https://developer.apple.com/documentation/arkit/camera_lighting_and_effects/occluding_virtual_content_with_people
    private func updatePeopleOcclusion(isEnabled: Bool) {
        print("\(#file)): isPeopleOcclusionEnabled is now \(String(describing: isEnabled).uppercased())")
        
        // Verify device support for People Occlusion
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            return
        }
        
        // Obtain the AR Session current configuration
        guard let configuration = self.session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        
        // Enable/disable People Occlusion by adding/removing the personSegmentationWithDepth option to/from the configuration’s frame semantics.
        if configuration.frameSemantics.contains(.personSegmentationWithDepth) {
            configuration.frameSemantics.remove(.personSegmentationWithDepth)
        } else {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        // Rerun the session to affect the configuration change.
        self.session.run(configuration)
    }
    
    private func updateObjectOcclusion(isEnabled: Bool) {
        print("\(#file): isObjectOcclusionEnabled is now \(String(describing: isEnabled).uppercased())")
        
        // Enable/disable Object Occlusion by adding/removing the occlusion option to/from the environment's scene understanding options.
        if self.environment.sceneUnderstanding.options.contains(.occlusion) {
            self.environment.sceneUnderstanding.options.remove(.occlusion)
        } else {
            self.environment.sceneUnderstanding.options.insert(.occlusion)
        }
    }
    
    private func updateLidarDebug(isEnabled: Bool) {
        print("\(#file): isLidarDebugEnabled is now \(String(describing: isEnabled).uppercased())")
        
        // Enable/disable LiDAR mesh visualization (debug mode) by adding/removing the showSceneUnderstanding option to/from the arView's debugOptions.
        if self.debugOptions.contains(.showSceneUnderstanding) {
            self.debugOptions.remove(.showSceneUnderstanding)
        } else {
            self.debugOptions.insert(.showSceneUnderstanding)
        }
    }
    
    private func updateMultiuser(isEnabled: Bool) {
        print("\(#file): isMultiuserEnabled is now \(String(describing: isEnabled).uppercased())")
    }
}

// MARK: - Object Deletion Methods
extension CustomGameARView {
    func enableObjectDeletion() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self)
                
        // Get entity at location, if any
        // NOTE: Finds the entity in the AR scene closest to the specified point.
        if let entity = self.entity(at: location) as? ModelEntity {
            modelDeletionManager.entitySelectedForDeletion = entity
        }
    }
}
