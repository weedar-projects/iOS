//
//  CarouselARVIew+Gestures.swift
//  CarouselARVIew+Gestures
//
//  Created by Bohdan Koshyrets on 8/19/21.
//
import ARKit
import SwiftUI
import RealityKit
import AVFoundation

extension CarouselARView {
    func addGestureRecognizers() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
        let animationOpenGesture = UISwipeGestureRecognizer(target: self, action: #selector(startOpenAnimation))
        let animationCloseGesture = UISwipeGestureRecognizer(target: self, action: #selector(startFinishAnimation))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomProduct(sender:)))
        
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(panGesture)
        tapGesture.numberOfTouchesRequired = 1
        
        animationOpenGesture.numberOfTouchesRequired = 1
        animationCloseGesture.numberOfTouchesRequired = 1
        
        panGesture.maximumNumberOfTouches = 1
        animationOpenGesture.direction = .up
        animationCloseGesture.direction = .down
        
        gestureHandler = GestureRecognizerDelegateHandler(tapGesture: tapGesture,
                                                          animationOpenGesture: animationOpenGesture,
                                                          animationCloseGesture: animationCloseGesture,
                                                          panGesture: panGesture,
                                                          zoomGesture: zoomGesture)
    }
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        let panTranslationX = gesture.translation(in: self).x
        handleHorizontalChange(gesture, panTranslationX: panTranslationX)
    }
    
    @objc func zoomProduct(sender: UIPinchGestureRecognizer) {
        
        switch state {
        case .detail(items: let objects):
            
            for object in objects {
                var newZoomLevel = properties.zoomLevel + Float(sender.scale - 1)
                
                if newZoomLevel > Scale.minZoom, newZoomLevel < Scale.maxZoom {
                    print("ok")
                } else {
                    (newZoomLevel >= Scale.maxZoom) ? (newZoomLevel = Scale.maxZoom) : (newZoomLevel = Scale.minZoom)
                }
                let finalScale = newZoomLevel * properties.selectedItemScale
                object.transform.scale = [finalScale, finalScale, finalScale]
                properties.zoomLevel = newZoomLevel
            }

            
            break
        case .overview:
            break
        }
        
        sender.scale = 1
    }
    
    @objc func onTap(sender: UITapGestureRecognizer) {
        
        feedbackGenerator?.prepare()

        lastScrollSpeed = 0
        let location = sender.location(in: self)
        if let object = self.entity(at: location) {
            print("That's \(object.name)")
     
            switch state {
            case .overview:
                feedbackGenerator?.impactOccurred(intensity: 0.5)
//                playSound(name: "select")
                lodHolder = nil

//                finishAnimation()
                
//                if properties.controllers[object.name] == nil {
//                    notificationFeedbackGenerator?.notificationOccurred(.success)
//
//
//                }
                
                updateHighlightedProduct(productName: object as! ModelEntity)
                
                if properties.controllers[object.name] != nil {
                    properties.controllers.removeValue(forKey: object.name)
                }
                
                state = .detail(items: [object])
                configureDetailedView(for: object)
                
                if tutorialStage == .tapChoose {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        self.tutorialStage = .swipeUp
                    }
                }

                print("SHOW OVERVIEW")
                
            case .detail(items: let selectedEntities):
                feedbackGenerator?.impactOccurred(intensity: 0.5)
//                playSound(name: "select")
                properties.controller = nil
                if let entity = selectedEntities.last {
                    configureOverview(entity)
                    finishAnimation()
                    state = .overview
                    
                }
                print("SHOW DETAIL")
            }
            
            gestureHandler?.configureGestures(for: state, view: self)
        }
    }
    
    @objc func startOpenAnimation() {
        switch state {
        case .detail(items: let objects):
            notificationFeedbackGenerator?.prepare()
//            playSound(name: "start")
            let object = objects.last!
            
            var objectTransform = object.transform
            objectTransform.rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, -1, 0))
            object.transform = objectTransform
            
            if properties.controllers[object.name] == nil {
                notificationFeedbackGenerator?.notificationOccurred(.success)
                
                playAnimation(for: object)
            }
            
            if tutorialStage == .swipeUp {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self.tutorialStage = .swipeDown
                }
            }
        default:
            break
        }
    }
    
    fileprivate func finishAnimation() {
        switch state {
        case .detail(items: let objects):
            let object = objects.last!
            if let controller = properties.controllers[object.name] {
                notificationFeedbackGenerator?.prepare()
                notificationFeedbackGenerator?.notificationOccurred(.success)
//                playSound(name: "end")
                controller.resume()
              
                self.properties.controller = nil
                properties.controllers.removeValue(forKey: object.name)
                
                if tutorialStage == .swipeDown {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        self.tutorialStage = .hide
                    }
                }
            }

        case .overview:
            break
        }
    }
    
    @objc func startFinishAnimation() {
        switch state {
        case .detail(items: _):
            finishAnimation()
        default:
            break
        }
    }
        
    fileprivate func rotateCarousel(_ lastSpeedReduced: CGFloat) {
        for anchor in productsAnchor.children {
            anchor.transform.rotation *= simd_quatf(angle: Float(lastSpeedReduced / 250), axis: SIMD3<Float>(0, -1, 0))
        }
    }
    
    func updateOverscroll(lastSpeed: CGFloat, segmentCenter: CGFloat) {
        let lastSpeedReduced = lastSpeed * 0.9
        
        lastScrollSpeed = lastSpeedReduced

        switch state {
        case .overview:
            if (segmentCenter < 0.0001) && (segmentCenter > -0.0001) { return }
            rotateCarousel(lastSpeedReduced + (segmentCenter * 10))
        case .detail(items: let objects):
            if (lastSpeedReduced < 0.001) && (lastSpeedReduced > -0.001) { return }
            for object in objects {
                object.transform.rotation *= simd_quatf(angle: Float(lastSpeedReduced / 90), axis: SIMD3<Float>(0, 1, 0))
            }
        }
    }
    
    func updateCursorPosition(for cursorEntity: Entity) {
        let distanceFromCamera: SIMD3<Float> = [1.5, 1.5, 1.5]
        
        // move down model in detailed view a little [0, -0.2, 0]
        let cameraFraming: SIMD3<Float> = [0, -0.1, 0]
        let cameraTransform: Transform = self.cameraTransform

        // 1. Calculate the local camera position, relative to the sceneEntity
        let localCameraPosition: SIMD3<Float> = self.productsAnchor.convert(position: cameraTransform.translation, from: nil)

        // 2. Get the forward-facing directional vector of the camera using the extension described above
        let cameraForwardVector: SIMD3<Float> = cameraTransform.matrix.forward + cameraFraming
        

        // 3. Calculate the final local position of the cursor using distanceFromCamera
        let finalPosition: SIMD3<Float> = localCameraPosition + cameraForwardVector
        * distanceFromCamera
        
        // 4. Apply the translation
        cursorEntity.transform.translation = finalPosition
    }
    
    func returnCursorPosition(for cursorEntity: Entity) -> SIMD3<Float> {
        let distanceFromCamera: SIMD3<Float> = [1, 1, 1]
        let cameraTransform: Transform = self.cameraTransform
        let localCameraPosition: SIMD3<Float> = self.productsAnchor.convert(position: cameraTransform.translation, from: nil)
        let cameraForwardVector: SIMD3<Float> = cameraTransform.matrix.forward
        return localCameraPosition + cameraForwardVector
        * distanceFromCamera
        
    }
    
    private func handleHorizontalChange(_ gesture: UIPanGestureRecognizer, panTranslationX: CGFloat) {
        switch state {
        case .overview:
            for anchor in productsAnchor.children {
                anchor.transform.rotation *= simd_quatf(angle: Float(panTranslationX / 350), axis: SIMD3<Float>(0, -1, 0))
            }
            if tutorialStage == .swipeLeftRight {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.tutorialStage = .tapChoose
                }
            }
            
        case .detail(items: let objects):
            for object in objects {
                object.transform.rotation *= simd_quatf(angle: Float(panTranslationX / 90), axis: SIMD3<Float>(0, 1, 0))
            }
            
        }
        gesture.setTranslation(.zero, in: self)
        lastScrollSpeed = (lastScrollSpeed + panTranslationX) / 2
    }
    

    func playSound(name: String) {
        guard let soundData = NSDataAsset(name: name)?.data  else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: soundData)
            player!.play()

        } catch let error {
            print("error play sond \(error.localizedDescription)")
        }
    }
}
