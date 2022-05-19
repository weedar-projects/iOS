//
//  CarouselARView+DetailedView.swift
//  CarouselARView+DetailedView
//
//  Created by Bohdan Koshyrets on 8/18/21.
//

import ARKit
import SwiftUI
import RealityKit
import Amplitude

struct DetailedViewProperties {
    var selectedProduct: Product?
    
    var anchorEntityPosition: SIMD3<Float>?
    var anchorEntityTransform: Transform?
    
    var modelEntityPosition: SIMD3<Float>?
    var modelEntityTransform: Transform?
    
    var controller: AnimationPlaybackController?
    
    var zoomLevel: Float = 1.0
    var selectedItemScale: Float = 0.0
    
    var controllers: [String: AnimationPlaybackController] = [:]
}


extension CarouselARView {
    
    func configureDetailedView(for object: Entity) {
        
        guard let parent = object.parent else {
            fatalError()
        }

        properties.zoomLevel = 1.0
        
        lodScale = object.scale.x
        
        let localLodScale = lodScale
        
        let detailedProductScale = localLodScale! / Scale.overview * Scale.detailedView
        
        
        print("NAME: \(object.name) \nID: \(object.id)\nSCALE: \(object.scale)")
        
        properties.selectedItemScale = detailedProductScale
        object.scale = [detailedProductScale, detailedProductScale, detailedProductScale]
        if UserDefaults.standard.bool(forKey: "EnableTracking"){
        Amplitude.instance().logEvent("3D_product_select", withEventProperties: ["product_id" : object.id])
        }
        properties.anchorEntityPosition = parent.position
        properties.anchorEntityTransform = parent.transform
        properties.modelEntityPosition = object.position
        properties.modelEntityTransform = object.transform
        object.parent?.position = [0, 0, 0]
        
        parent.transform.rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, -1, 0))

//        let modelID = Int(object.name)!
        
//        let model = ARModelsManager.shared.itemNamesDemo[modelID]!
        
//        manager.asyncLoadCompletion(name: model.filename, id: modelID) { hqEntity in
//            switch self.state {
//            case .detail(items: let arrayWithLq):
//
//                print("\(model.filename)")
//                hqEntity.scale = [detailedProductScale, detailedProductScale, detailedProductScale]
//
//                hqEntity.components[CollisionComponent.self] = CollisionComponent(
//                    shapes: [.generateBox(size: [0.25 / localLodScale!, 1.5 / localLodScale!, 0.1 / localLodScale!])],
//                    mode: .trigger,
//                    filter: .sensor)
//
//                hqEntity.generateCollisionShapes(recursive: true)
//                hqEntity.position = [0, -10, -self.radius]
//
//                self.lodHolder = object
//
//                parent.addChild(hqEntity)
//
//                // need to add two models to remove visual glitch when trnsitioning from LQ to HQ models
//                // LQ model is removed on the next frame inside func session(_, didUpdate)
//                var newArray = arrayWithLq
//                newArray.append(hqEntity)
//                self.state = .detail(items: newArray)
//
//            case .overview:
//                return
//            }
//        }
    }
    
    func configureOverview(_ selectedEntity: Entity) {
        guard let parent = selectedEntity.parent else {
            fatalError("No parent found for entity \(selectedEntity.name)")
        }
        
        if let lqModel = lodHolder {
            parent.addChild(lqModel)
            selectedEntity.removeFromParent()
            
            lqModel.position = properties.modelEntityPosition!
            lqModel.transform.rotation = properties.modelEntityTransform!.rotation
            if let lodScale = lodScale {
                lqModel.scale = [lodScale, lodScale, lodScale]
            } else {
                fatalError("no lod scale found!")
            }
            lqModel.parent!.position = properties.anchorEntityPosition!
            lqModel.parent!.transform.rotation = properties.anchorEntityTransform!.rotation
        } else {
            selectedEntity.position = properties.modelEntityPosition!
            selectedEntity.transform.rotation = properties.modelEntityTransform!.rotation
            if let lodScale = lodScale {
                selectedEntity.scale = [lodScale, lodScale, lodScale]
            } else {
                fatalError("no lod scale found!")
            }
            selectedEntity.parent!.position = properties.anchorEntityPosition!
            selectedEntity.parent!.transform.rotation = properties.anchorEntityTransform!.rotation
        }
        
    }
    
    func playAnimation(for entity: Entity) {
        for animation in entity.availableAnimations{
            let product = ProductsViewModel.shared.getProduct(id: Int(entity.name)!)!
            
            let pauseInterval = product.animationDuration
            
            print("\n\n------START ANIMATION------ \nanimation duration: \(pauseInterval) \nNAME: \(entity.name), \nID: \(entity.id), \nNAME: \(entity.availableAnimations.first) \nAnimation name:\(animation.name) \n")
            
            let name = entity.name
            
            var controller: AnimationPlaybackController


            if #available(iOS 15.0, *) {
                 controller = entity.playAnimation(animation)
            } else {
                // Fallback on earlier versions
                controller = entity.playAnimation(animation, transitionDuration: 0.0, startsPaused: true)
            }

            controller.resume()

            properties.controllers[name] = controller

            DispatchQueue.main.asyncAfter(deadline: .now() + pauseInterval) {
                if let controller = self.properties.controllers[name] {
                    controller.pause()
                }
            }
        }
    }
    
    func animateTransition(for entity: Entity) {
        let scale = Scale.overview
        let rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, -1, 0))
        let transform = Transform(scale: [scale, scale, scale], rotation: rotation, translation: returnCursorPosition(for: entity))
        _ = entity.move(to: transform,
                        relativeTo: nil,
                        duration: 0.25,
                        timingFunction: .easeInOut)
    }
    
    func animateAnchorTransition(for entity: Entity) {
        let rotation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, -1, 0))
        let transform = Transform(scale: entity.scale, rotation: rotation, translation: [0, 0, 0])
        _ = entity.move(to: transform,
                        relativeTo: nil,
                        duration: 1.0,
                        timingFunction: .easeInOut)
    }
}
