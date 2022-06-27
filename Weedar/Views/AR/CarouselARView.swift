//
//  CarouselARView.swift
//  CarouselARView
//
//  Created by Bohdan Koshyrets on 8/11/21.
//

import ARKit
import SwiftUI
import RealityKit

enum ARViewState {
    case overview
    case detail(items: [Entity])
}

class Lighting: Entity, HasDirectionalLight {
    
    required init() {
        super.init()
        
        self.light = DirectionalLightComponent(color: UIColor(Color.col_white),
                                           intensity: 1300,
                                    isRealWorldProxy: false)
    }
}

class SpotLight: Entity, HasSpotLight {
    required init() {
        super.init()
        self.light = SpotLightComponent(color: UIColor(Color.col_cold_ar_light),
                                        intensity: 15000,
                                        innerAngleInDegrees: 60,
                                        outerAngleInDegrees: 179, // greater angle – softer shadows
            attenuationRadius: 35) // can't be Zero
    }
}

class CarouselARView: ARView, ObservableObject {
    
    struct ProductAR {
        let name: String
        let id: Int
        let model: ModelEntity?
    }
    
    @Published var highlightedProduct: ProductAR? = nil
    @Published var tutorialStage: Tutorial.Stage = .waitToStart
    
    var shouldShowDescriptionCard: Bool = true
    var productsViewModel = ProductsViewModel.shared
    
    var radius: Float = 2.0
    
    var state: ARViewState = .overview
    var coachingOverlay: ARCoachingOverlayView? = nil
    
    var entities: [Entity] = []
    var anchor: AnchorEntity!
    var productsAnchor: AnchorEntity!
    var player: AVAudioPlayer?
    
    var properties: DetailedViewProperties = .init()
    
    var gestureHandler: GestureRecognizerDelegateHandler?
    
    var lastScrollSpeed: CGFloat = 0
    
    var manager: ProductManager
    
    var selectionGenerator: UISelectionFeedbackGenerator? = nil
    var feedbackGenerator: UIImpactFeedbackGenerator? = nil
    var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    
    var lodHolder: Entity? = nil
    var lodScale: Float? = nil
    
    var paused = false
    var anchorFound = false
    var shouldDoPerFrameUpdates = false
    
    var angle: Float?
    
    func resetState() {
#if !targetEnvironment(simulator)
        
        highlightedProduct = nil
        
        finishAnimation()
        
        switch state {
        case .overview:
            break
        case .detail(let selectedEntities):
            properties.controller = nil
            configureOverview(selectedEntities.first!)
            state = .overview
        }
        
        let config = self.session.configuration!
        self.session.run(config, options: .resetTracking)
        
        angle = nil
#endif
    }

    func toTrackingState(itemsCount: Int) {
        print("tracking")
        
        if !anchorFound {
            let productsAnchor = AnchorEntity()
            self.productsAnchor = productsAnchor
            self.anchor.addChild(productsAnchor)
            
            if let angle = angle {
                productsAnchor.transform.rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
            }
                
            self.addEmptyAnchors(itemsCount: itemsCount)
            
            self.shouldDoPerFrameUpdates = true
            
        }
        anchorFound = true
    }
    
    func showDescriptionCard() {
        shouldShowDescriptionCard = true
    }
    
    required init(frame frameRect: CGRect) {
        manager = ProductManager(items: ARModelsManager.shared.itemNamesDemo,
                                 scale: Scale.overview,
                                 radius: radius)
        
        super.init(frame: frameRect)
        
        let spotLight = SpotLight().light
        let directionLight = Lighting().light
        
#if !targetEnvironment(simulator)
        self.renderOptions.insert(.disableMotionBlur)
        self.renderOptions.insert(.disableGroundingShadows)
        self.addCoaching(in: frameRect)
#endif
        
        
        let anchor = AnchorEntity()
        self.scene.addAnchor(anchor)
        
        self.anchor = anchor
        self.anchor.components.set(directionLight)
        self.anchor.components.set(spotLight)
        
        toTrackingState(itemsCount: ARModelsManager.shared.itemNamesDemo.count)
        
#if !targetEnvironment(simulator)
        self.addGestureRecognizers()
        self.session.delegate = self
#endif
        
        
//                self.addPointLight()
        feedbackGenerator = UIImpactFeedbackGenerator()
        selectionGenerator = UISelectionFeedbackGenerator()
        notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    }
    
    func updateProducts(items: [Int: ModelTuple]){
        pauseScene()
        manager = ProductManager(items: items,
                                 scale: Scale.overview,
                                 radius: radius)
        anchor.removeChild(productsAnchor)
        self.anchorFound = false
        toTrackingState(itemsCount: items.count)
        self.resumeScene()
        showDescriptionCard()
    }
    
    func pauseScene() {
#if !targetEnvironment(simulator)
        //        anchor?.isEnabled = false
        shouldShowDescriptionCard = false
        highlightedProduct = nil
        
        let config = self.session.configuration!
        session.run(config, options: .resetTracking)
        
        switch state {
        case .overview:
            break
        case .detail(let selectedEntities):
            properties.controller = nil
            configureOverview(selectedEntities.first!)
            state = .overview
        }
        
        session.pause()
        paused = true
        for anchor in productsAnchor.children {
            manager.monitorRotation(forAnchor: anchor as! ModelEntity, putBackModels: true)
        }
#endif
    }
    
    func resumeScene() {
#if !targetEnvironment(simulator)
        if paused {
            paused = false
            let config = self.session.configuration!
            session.run(config)
            //            anchor?.isEnabled = true
        }
#endif
    }
    
    func addPointLight() {
//#if !targetEnvironment(simulator)
        let pointLight = PointLight()
        pointLight.light.color = .red
        pointLight.light.intensity = 400000
        pointLight.light.attenuationRadius = 20.0
        pointLight.position = [0, 2, 2.8]
        pointLight.name = "pointLight"
        
                    anchor?.addChild(pointLight)
//#endif
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func doHighlightingAnimation(_ model: ModelEntity) {
        func animateScale(for model: ModelEntity, scale: Float) {
            let newScale = model.transform.scale * scale
            let transform = Transform(scale: newScale, rotation: model.transform.rotation, translation: model.transform.translation)
            if let parent = model.parent {
                model.move(to: transform, relativeTo: parent, duration: 0.15, timingFunction: .easeOut)
            }
        }
        
        // animate prev
        if let prevModel = highlightedProduct?.model {
            animateScale(for: prevModel, scale: 1/Scale.highlightScale)
        }
        
        // aminate new
        animateScale(for: model, scale: Scale.highlightScale)
    }
    
    func updateHighlightedProduct(productName model: ModelEntity) {
        if !shouldShowDescriptionCard {
            highlightedProduct = nil
            return
        }
        
        switch state {
        case .overview:
            if let id = Int(model.name) {
                if let product = productsViewModel.getProduct(id: id) {
                    if product.id != highlightedProduct?.id {
                        doHighlightingAnimation(model)
                        highlightedProduct = ProductAR(name: product.name, id: product.id, model: model)
                        selectionGenerator?.selectionChanged()
                    }
                }
            }
        case .detail(_):
            return
        }
        
        
    }
    
    func addEmptyAnchors(itemsCount: Int) {
        
        
        let items = itemsCount == 1 ? itemsCount : 12
        
        print("ITEMS COUNT: \(items)")
        for index in 1...12 {
            let containerModel = ModelEntity()
            
            self.productsAnchor.addChild(containerModel)
            
            containerModel.position = [0, 0, -2]//returnCursorPosition(for: containerAnchor)
            containerModel.transform.rotation *= simd_quatf(angle: (.pi/Float((12/2))) * Float(index), axis: SIMD3<Float>(0, -1, 0))
        }
    }
}


extension BinaryInteger {
    var isEven: Bool { isMultiple(of: 2) }
    var isOdd:  Bool { !isEven }
}
