//
//  CarouselARView+Carousel.swift
//  CarouselARView+Carousel
//
//  Created by Bohdan Koshyrets on 8/26/21.
//

import RealityKit
import Combine
import SwiftUI
import AudioToolbox

class ProductManager {
    init(items: [Int: ModelTuple], scale: Float, radius: Float) {
        self.scale = scale
      
        var queueTemp: [Int] = []
     
        for item in items {
            queueTemp.append(item.key)
        }
//        while queueTemp.count < 12 {
//            queueTemp += queueTemp
//        }
        
        self.queue = queueTemp.sorted(by: >)
        
        self.radius = radius
    }
    
    var queue: [Int]
    var scale: Float
    var radius: Float
    
    func monitorRotation(forAnchor anchor: ModelEntity, putBackModels: Bool = false) {
        let pie: Int
        
               if isInsideVisibleWindow(pie: pie) {
            if isModelNeedsLoading(for: anchor) {
                anchor.isEnabled = false
                let modelID = getModelIDToLoad(forPie: pie)
                if let product = ProductsViewModel.shared.getProduct(id: modelID) {
                    print("--- --- ---")
                    print("modelID: \(modelID)")
                    if product.modelHighQualityLink.hasSuffix(".usdz") {
                        self.asyncLoad(name: product.modelHighQualityLink, id: modelID, for: anchor, product: product)
                    }
                }
            }
        } else {
            // check if anchor has models to put back to the queue
            if isAnchorContainsAnyModels(anchor: anchor) {
                let modelID = Int(anchor.children.first!.name)!
                insertModelName(forPie: pie, modelID: modelID)
                anchor.children.removeAll()
            }
        }
    }
    
    
    func setFirstModelId(id: Int){
        print("Queue: \(queue)")
        if queue[3] != id{
            queue.append(queue[3])
            queue.insert(id, at: 3)
            queue = uniq(source: queue).sorted(
            print("Queue: \(queue)")
        }
    }
    
    private func uniq<S: Sequence, T: Hashable> (source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]() // возвращаемый массив
        var added = Set<T>() // набор - уникальные значения
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    private func isInsideVisibleWindow(pie: Int) -> Bool {
        return (pie < 2 && pie > -2)
    }
    
    private func isModelNeedsLoading(for anchor: ModelEntity) -> Bool {
        return (anchor.children.isEmpty && anchor.isEnabled)
    }
    
    private func isAnchorContainsAnyModels(anchor: ModelEntity) -> Bool {
        return !anchor.children.isEmpty
    }
    
    private func pie(forAnchor anchor: ModelEntity) -> Int {
        let rawRotation = anchor.transform.matrix.eulerAngles.y
        let pie = Int(4 / .pi * rawRotation)
        return pie
    }
    
    func segmentCenter(for anchor: ModelEntity) -> CGFloat {
        let angle = anchor.transform.matrix.eulerAngles.y
        let segment = (angle + .pi).truncatingRemainder(dividingBy: (.pi / 4))
        let segmentCenter = segment - (.pi / 12)
        
        return CGFloat(segmentCenter)
    }
    
    private func getModelIDToLoad(forPie pie: Int) -> Int {
        // gives model id to load depending on
        // what side user is turing the carousel to
        if pie > 0 {
            return queue.removeLast()
        } else {
            return queue.removeFirst()
        }
    }
    
    private func insertModelName(forPie pie: Int, modelID: Int) {
        if pie > 0 {
            queue.append(modelID)
        } else {
            queue.insert(modelID, at: 0)
            
        }
    }
    
    func loadModel(_ product: Product, for anchor: AnchorEntity, completion: ((ModelEntity) -> Void)?) {
        // if file exists -> load form directory
        // else load from internet -> load from directory
        ProductsViewModel.shared.getModel(id: product.modelHighQualityLink) {
            self.asyncLoadFromDirectory(product, for: anchor) { model in
                print("loaded \(model.name)")
                completion?(model)
            }
        }
    }
    
    func asyncLoadCompletion(name: String, id: Int, completion: @escaping (ModelEntity) -> Void) {
        var cancellable: AnyCancellable? = nil
        
           let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
           let url = URL(fileURLWithPath: path)
           let pathComponent = url.appendingPathComponent(name + ".usdz")
   
           print("\n\n------OPEN DETAIL------ \nPATH: \(pathComponent), \nwith name: \(name)\n\n")
   
           cancellable = ModelEntity.loadModelAsync(contentsOf: pathComponent, withName: name)
            .sink(receiveCompletion: { error in
                print("Unexpected error: \(error)")
                
                let boxMesh = MeshResource.generateBox(size: [0.5, 0.5, 0.5])
                let simpleMaterial = SimpleMaterial(color: .green, isMetallic: false)
                let noModelBox = ModelEntity(mesh: boxMesh, materials: [simpleMaterial])
                noModelBox.name = String(id)
                completion(noModelBox)
                cancellable?.cancel()
            }, receiveValue: { entity in
                entity.name = "\(id)"
                completion(entity)
                cancellable?.cancel()
            })
    }
    
    private func asyncLoad(name: String, id: Int, for anchor: ModelEntity, product: Product) {
        var cancellable: AnyCancellable? = nil
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let pathComponent = url.appendingPathComponent(name + ".usdz")
       
        DispatchQueue.main.async {
            cancellable = ModelEntity.loadModelAsync(contentsOf: pathComponent, withName: name)
                .sink(receiveCompletion: { error in
                    print("Unexpected error: \(error)")
                    
                    let boxMesh = MeshResource.generateBox(size: [0.5, 0.5, 0.5])
                    let simpleMaterial = SimpleMaterial(color: .green, isMetallic: false)
                    let noModelBox = ModelEntity(mesh: boxMesh, materials: [simpleMaterial])
                    noModelBox.name = String(id)
                    noModelBox.position = [0, -1, -self.radius]
                    anchor.addChild(noModelBox)
                    noModelBox.components[CollisionComponent.self] = CollisionComponent(
                        shapes: [.generateBox(size: [0.25, 0.8, 0.1])],
                        mode: .trigger,
                        filter: .sensor)
                    noModelBox.generateCollisionShapes(recursive: true)
                    anchor.isEnabled = true
                    
                    cancellable?.cancel()
                }, receiveValue: { entity in
                    entity.name = "\(id)"
                    entity.position = [0, -1, -2]
                    
                    if let scale = product.aspectRatio, scale != 0 {
                        entity.scale = [scale, scale, scale]
                        print("scales box \([0.25 / scale, 0.8 / scale, 0.1 / scale])")
                        entity.components[CollisionComponent.self] = CollisionComponent(
                            shapes: [.generateBox(size: [0.25 / scale, 1.5 / scale, 0.1 / scale])],
                            mode: .trigger,
                            filter: .sensor)
                    } else {
                        entity.scale = [self.scale, self.scale, self.scale]
                        entity.components[CollisionComponent.self] = CollisionComponent(
                            shapes: [.generateBox(size: [0.25, 0.8, 0.1])],
                            mode: .trigger,
                            filter: .sensor)
                    }
                    entity.generateCollisionShapes(recursive: true)
                    
                    anchor.addChild(entity)
                    anchor.isEnabled = true
                    cancellable?.cancel()
                })
        }
    }

    
    private func asyncLoadFromDirectory(_ product: Product, for anchor: AnchorEntity, completion: @escaping (ModelEntity) -> Void) {
        let productID = product.id
        let modelFilename = product.modelHighQualityLink
        
        var cancellable: AnyCancellable? = nil
        let dir = try! FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = dir.appendingPathComponent("\(modelFilename)")
        print("Appended File URL: \(fileURL) ")
        print("About to async load product id: \(productID)")
        
        DispatchQueue.main.async {
            cancellable = ModelEntity.loadModelAsync(contentsOf: fileURL)
                .sink(receiveCompletion: { error in
                    print("Unexpected error: \(error)")
                    
                    let boxMesh = MeshResource.generateBox(size: [0.5, 0.5, 0.5])
                    let simpleMaterial = SimpleMaterial(color: .green, isMetallic: false)
                    let noModelBox = ModelEntity(mesh: boxMesh, materials: [simpleMaterial])
                    noModelBox.name = String(productID)
                    noModelBox.position = [0, -1, -self.radius]
                    anchor.addChild(noModelBox)
                    
                    anchor.isEnabled = true
                    cancellable?.cancel()
                    completion(noModelBox)
                }, receiveValue: { entity in
                    entity.name = String(productID)
                    entity.position = [0, -1, -self.radius]
                    entity.scale = [self.scale, self.scale, self.scale]
                    entity.components[CollisionComponent.self] = CollisionComponent(
                        shapes: [.generateBox(size: [0.25, 0.8, 0.1])],
                        mode: .trigger,
                        filter: .sensor)
                    entity.generateCollisionShapes(recursive: true)
                    
                    anchor.addChild(entity)
                    anchor.isEnabled = true
                    cancellable?.cancel()
                    completion(entity)
                })
        }
    }
}
