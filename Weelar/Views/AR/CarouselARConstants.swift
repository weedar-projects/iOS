//
//  CarouselARConstants.swift
//  CarouselARConstants
//
//  Created by Bohdan Koshyrets on 8/23/21.
//

import Foundation
import SwiftUI

typealias ModelTuple = (filename: String, animation: Double)

struct CarouselConstants {
    static let placeholder = "placeholder"
}

struct Scale {
    static let overview: Float = 3.0
    static let detailedView: Float = 2.0
    static let minZoom: Float = 1.0
    static let maxZoom: Float = 1.9
    static let highlightScale: Float = 1.1
}

class ARModelsManager: ObservableObject {
    
    static let shared = ARModelsManager()
    
    var itemNamesDemo: [Int: ModelTuple] = [:]

    @Published var allModelCount: Int = 0
    
    @Published var currentLoadedModel: Int = 0
   
    @Published private var products: [Product] = []
    
    var carusel: CarouselARView?
    
    let fileManager = FileManager.default
    let notificationCenter = NotificationCenter.default
       
    
    init() {
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
//        self.fetchProducts {
//            self.getAllModels()
//        }
    }
    
    @objc func appMovedToForeground() {
        restartGetModels()
    }

    func restartGetModels(){
        if currentLoadedModel < allModelCount && !products.isEmpty{
            print("RestartGet Models")
            getAllModels()
        }
    }
    
     func fetchProducts(finished: @escaping() -> Void) {
        ProductRepository
            .shared
            .getProducts(withParameters: FiltersRequestModel()) { result in
                switch result {
                case .success(let products):
                    DispatchQueue.main.async {
                        self.products.removeAll()
                        self.products.append(contentsOf: products)
                        finished()
                    }
                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                    break
                }
            }
    }
    
     func getAllModels(){
        for product in products {
            if product.modelHighQualityLink.hasSuffix(".usdz"){
                print("\n\n---------\nAPPEND \(product.id)")
                print("animationDuration \(product.animationDuration)")
                print("modelHighQualityLink \(product.modelHighQualityLink)")
                
                itemNamesDemo[product.id] = (product.modelHighQualityLink, product.animationDuration)
                                
                let url = "\(BaseRepository().baseURL)/model/" + product.modelHighQualityLink
                
                methodLoadModelData(argIdCount: product.id, argWebURLStr: url) { value in

                    DispatchQueue.main.async {
                        self.currentLoadedModel = self.getFilesCount()
                    }
                }
            }
        }
        
        self.allModelCount = itemNamesDemo.count
        
        self.currentLoadedModel = getFilesCount()
                
        carusel = CarouselARView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    }
    
    
    
    func getFilesCount() -> Int{
        let fileManager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let dirContents = try? fileManager.contentsOfDirectory(atPath: documentsPath)
        let count = dirContents?.count
        
        print("Files in ar folder count: \(count)")
        return count ?? 0
    }
    
    func removeCache(){
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs where fileURL.pathExtension == "usdz" {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch  { print(error) }
    }
    
    private func methodLoadModelData(argIdCount: Int,
                                     argWebURLStr: String,
                                     argCompletionBlock: @escaping (Bool) -> Void) {

        let fileNameStr = ARModelsManager.shared.itemNamesDemo[argIdCount]!.filename
            
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileNameStr + ".usdz") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
            } else {
                DispatchQueue.global().async {
                    let theURL = URL(string: argWebURLStr)
                    if theURL != nil {
                        do {
                            var theData: Data? = nil
                            try theData = Data(contentsOf: theURL!)
                            
                            if theData != nil {
                                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                                let url = URL(fileURLWithPath: path)
                                
                                let pathComponent = url.appendingPathComponent(fileNameStr + ".usdz")
                                
                                do {
                                    try theData!.write(to: pathComponent, options: .atomic)
                                    argCompletionBlock(true)
                                    print("\n\n----SAVE Model---- LOAD FROM \(argWebURLStr), \nModel id ID: \(argIdCount) \nModel name ID: \(fileNameStr) \nPART TO SAVE: \(pathComponent)\n\n")
                                } catch (let error) {
                                    print("DATA FAILED1")
                                    print(error)
                                    argCompletionBlock(false)
                                }
                            }
                        } catch (let error) {
                            print("DATA FAILED2")
                            argCompletionBlock(false)
                            print(error)
                        }
                    }
                   
                }
            }
        } else {
            argCompletionBlock(false)
        }
        
//        if theBool {
//            print("DATA AVAILABLE")
//            finalBool = true
//            argCompletionBlock(finalBool)
//
//        } else {
//            print("DATA NOT AVAILABLE")
//
//            DispatchQueue.global().async {
//                let theURL = URL(string: argWebURLStr)
//                if theURL != nil {
//                    do {
//                        var theData: Data? = nil
//                        try theData = Data(contentsOf: theURL!)
//
//                        if theData != nil {
//                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//                            let url = URL(fileURLWithPath: path)
//
//                            let pathComponent = url.appendingPathComponent(fileNameStr + ".usdz")
//
//                            do {
//                                try theData!.write(to: pathComponent, options: .atomic)
//
//                                print("\n\n----SAVE Model---- LOAD FROM \(argWebURLStr), \nModel id ID: \(argIdCount) \nModel name ID: \(fileNameStr) \nPART TO SAVE: \(pathComponent)\n\n")
//                            } catch (let error) {
//                                print("DATA FAILED1")
//                                print(error)
//                            }
//
//
//                            print("DATA SAVED")
//                            UserDefaults.standard.set(true, forKey: fileNameStr + argWebURLStr)
//                            finalBool = true
//                        }
//                    } catch (let error) {
//                        print("DATA FAILED2")
//
//                        print(error)
//                    }
//                }
//                    argCompletionBlock(finalBool)
//            }
//        }
    }
}
