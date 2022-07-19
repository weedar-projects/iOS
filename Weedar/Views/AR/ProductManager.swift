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
    init(items: [Int: ModelTuple], scale: Float, radius: Float, openById: Int = 0) {
        self.scale = scale
        self.radius = radius
        
        var queueTemp: [Int] = []
        
        queue = []
        
        for item in items {
            queueTemp.append(item.key)
        }
        
        while queueTemp.count < 8{
            queueTemp += queueTemp
        }
          
        self.queue = queueTemp
        
        if openById != 0{
            setFirstModelId(id: openById)
        }
        print("Queue: \(queue)")
    }
    
    var queue: [Int]
    var loadedModels: [Int] = []
    var scale: Float
    var radius: Float
    
    func loadModels(items: [Int: ModelTuple]){
        self.queue.removeAll()
        
        var queueTemp: [Int] = []
     
        for item in items {
            queueTemp.append(item.key)
        }
        
        while queueTemp.count < 12 {
            queueTemp += queueTemp
        }
        
//        self.queue = queueTemp.sorted(by: ({$0 < $1}))
//        setFirstModelId(id: queueTemp.first ?? 0)
//        self.queue = queue
        print("Queue: \(queue)")
    }
    
    func monitorRotation(forAnchor anchor: ModelEntity, putBackModels: Bool = false) {
        let pie: Int
        
        if !putBackModels {
            pie = self.pie(forAnchor: anchor)
        } else {
            pie = 4
        }
        
        if isInsideVisibleWindow(pie: pie) {
            if isModelNeedsLoading(for: anchor) {
                anchor.isEnabled = false
                let modelID = getModelIDToLoad(forPie: pie)
                print("modelID: \(modelID)")
                if let product = ProductsViewModel.shared.getProduct(id: modelID) {
                    print("--- --- ---")
                    print("modelID: \(modelID)")
                    if product.modelHighQualityLink.hasSuffix(".usdz") {
                        print("LOADED MODELS \(loadedModels)\n QUEU: \(queue)")
                        self.asyncLoad(name: product.modelHighQualityLink, id: modelID, for: anchor, product: product)
                    }
                }else{
                    print("fail to load: \(modelID)")
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
        print("Queue FITLRST : \(queue)")
        if queue[0] != id{
            queue.append(queue[0])
            queue.insert(id, at: 0)
            queue = uniq(source: queue)
            print("Queue LAST: \(queue)")
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
        let pie = Int(3  / .pi * rawRotation)
        return pie
    }
    
    func segmentCenter(for anchor: ModelEntity) -> CGFloat {
        let angle = anchor.transform.matrix.eulerAngles.y
        
        let segment = (angle + .pi).truncatingRemainder(dividingBy: (.pi / 3))
        let segmentCenter = segment - (.pi / 12)
//        print("ANGEL: \(angle) | SEGMENT: \(segment) | SEGMENTCENTER: \(segmentCenter)")
        return CGFloat(segmentCenter)
    }
    
    private func getModelIDToLoad(forPie pie: Int) -> Int {
        // gives model id to load depending on
        // what side user is turing the carousel to
        if pie > 0 {
            print("queue.removeLast \(queue.last)")
            if let quueLast = queue.last{
                return queue.removeLast()
            }else{
                return 0
            }
        } else {
            if let quueLast = queue.first{
                return queue.removeFirst()
            }else{
                return 0
            }
        }
    }
    
    private func insertModelName(forPie pie: Int, modelID: Int) {
        if pie > 0 {
            queue.append(modelID)
        } else {
            queue.insert(modelID, at: 0)
        }
    }
    
    func loadModel(_ product: ProductModel, for anchor: AnchorEntity, completion: ((ModelEntity) -> Void)?) {
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
    
    private func asyncLoad(name: String, id: Int, for anchor: ModelEntity, product: ProductModel) {
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

    private func asyncLoadEntityModel(name: String, id: Int, for anchor: ModelEntity, product: Product, boxColor: UIColor = UIColor.green) {
        var cancellable: AnyCancellable? = nil
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let pathComponent = url.appendingPathComponent(name + ".usdz")
       
        DispatchQueue.main.async {
            cancellable = ModelEntity.loadModelAsync(contentsOf: pathComponent, withName: name)
                .sink(receiveCompletion: { error in
                    print("Unexpected error: \(error)")
                    
                    let boxMesh = MeshResource.generateBox(size: [0.5, 0.5, 0.5])
                    let simpleMaterial = SimpleMaterial(color: boxColor, isMetallic: false)
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
                    let boxMesh = MeshResource.generateBox(size: [0.5, 0.5, 0.5])
                    let simpleMaterial = SimpleMaterial(color: boxColor, isMetallic: false)
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
                })
        }
    }
    
    private func asyncLoadFromDirectory(_ product: ProductModel, for anchor: AnchorEntity, completion: @escaping (ModelEntity) -> Void) {
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

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
