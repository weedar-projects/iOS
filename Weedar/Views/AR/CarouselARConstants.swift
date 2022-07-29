//
//  CarouselARConstants.swift
//  CarouselARConstants
//
//  Created by Bohdan Koshyrets on 8/23/21.
//

import Foundation
import SwiftUI
import Combine


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

    @Published var allModelCount: Int = 0{
        didSet{
            print("allModelCount \(allModelCount)")
        }
    }
    
    @Published var currentLoadedModel: Int = 0{
        didSet{
            print("currentLoadedModel \(currentLoadedModel)")
        }
    }
   
    @Published private var products: [Product] = []
    @Published private var filteredProducts: [ProductModel] = []
    
    var carusel: CarouselARView?
    
    let downloadManager = DownloadManager()
    
    let fileManager = FileManager.default
    let notificationCenter = NotificationCenter.default
       
    
    init() {
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.getProducts(filters: CatalogFilters()) {
            print("INIT \(self.filteredProducts)")
            self.getAllModels()
        }
    }
    
    
    func downloadModels(){
        
        let urls = modelUrlsToLoad.compactMap { URL(string: $0) }
            
            let completion = BlockOperation {
                print("all done")
            }
            
            for url in urls {
                let operation = downloadManager.queueDownload(url)
                completion.addDependency(operation)
            }

            OperationQueue.main.addOperation(completion)
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
    
    //get product
    func getProducts(categoryId: Int = -1, filters: CatalogFilters?, finish: @escaping ()->Void = {}){
        self.filteredProducts = []
        
        var params: [String : Any] = [:]
        
        if let filters = filters {
            params = composeFilters(categoryId: categoryId, catalogFilters: filters)
        }else{
            if categoryId != -1{
                params = [CatalogFilterKey.type.rawValue : categoryId]
            }
        }
         
        API.shared.request(rout: .getProductsList, parameters: params) { result in
            switch result{
            case let .success(data):
                for product in data.arrayValue{
                    self.filteredProducts.append(ProductModel(json: product))
                }
                finish()
            case .failure(_):
                break
            }
        }
    }
    
    
    
    func updateModels(finish: @escaping ([Int: ModelTuple])->Void = {_ in}){
        var updatedItems: [Int: ModelTuple] = [:]
        for product in filteredProducts {
            if product.modelHighQualityLink.hasSuffix(".usdz"){
                updatedItems[product.id] = (product.modelHighQualityLink, product.animationDuration)
            }
        }
        finish(updatedItems)
    }
    
    var modelUrlsToLoad: [String] = []
    
     func getAllModels(){
         
         for product in filteredProducts {
             modelUrlsToLoad.append("\(BaseRepository().baseURL)/model/" + product.modelHighQualityLink)
         }
         
         self.downloadModels()
         
//        for product in filteredProducts {
//            if product.modelHighQualityLink.hasSuffix(".usdz"){
//
//                print("\n\n---------\nAPPEND \(product.id)")
//                print("animationDuration \(product.animationDuration)")
//                print("modelHighQualityLink \(product.modelHighQualityLink)")
//
//                itemNamesDemo[product.id] = (product.modelHighQualityLink, product.animationDuration)
//
//                let url = "\(BaseRepository().baseURL)/model/" + product.modelHighQualityLink
//
//                methodLoadModelData(argIdCount: product.id, argWebURLStr: url) { value in
//
//                    DispatchQueue.main.async {
//                        self.currentLoadedModel = self.getFilesCount()
//                    }
//                }
//            }
//        }
//
//        print("filteredProducts: \(filteredProducts)")
//        self.allModelCount = itemNamesDemo.count
//
//        self.currentLoadedModel = getFilesCount()
                
        carusel = CarouselARView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    }
    
    
    private func composeFilters(categoryId: Int, catalogFilters: CatalogFilters) -> [String: Any] {
        var filters: [String : Any] = [:]
        
        if categoryId != -1{
            filters = [CatalogFilterKey.type.rawValue : categoryId]
        }
        if let search = catalogFilters.search{
            filters.merge(dict: [CatalogFilterKey.search.rawValue : search])
        }
        if let brand = catalogFilters.brands{
            filters.merge(dict: [CatalogFilterKey.brand.rawValue : convertToArray(value: brand)])
        }
        if let effect = catalogFilters.effects{
            filters.merge(dict: [CatalogFilterKey.effect.rawValue : convertToArray(value: effect)])
        }
        if let priceFrom = catalogFilters.priceFrom{
            filters.merge(dict: [CatalogFilterKey.priceFrom.rawValue : priceFrom])
        }
        if let priceTo = catalogFilters.priceTo{
            filters.merge(dict: [CatalogFilterKey.priceTo.rawValue : priceTo])
        }
        
        return filters
    }
    private func convertToArray(value: Set<Int>) -> [Int]{
         var int: [Int] = []
         for value in value {
             int.append(value)
         }
         return int
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



//class DownloadManager {
//    static let shared = DownloadManager()
//
//
//    var session : URLSession!
//    var queue : OperationQueue!
//
//    var progressValue = 0{
//        didSet{
//            print("progress: \(progressValue)")
//        }
//    }
//
//    init(){
//        session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
//        queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//    }
//
//
//    func download() {
//        let completionOperation = BlockOperation {
//            print("finished download all")
//        }
//
//        let urls = [
//            URL(string: "https://github.com/fluffyes/AppStoreCard/archive/master.zip")!,
//            URL(string: "https://github.com/fluffyes/currentLocation/archive/master.zip")!,
//            URL(string: "https://github.com/fluffyes/DispatchQueue/archive/master.zip")!,
//            URL(string: "https://github.com/fluffyes/dynamicFont/archive/master.zip")!,
//            URL(string: "https://github.com/fluffyes/telegrammy/archive/master.zip")!
//        ]
//
//        for (index, url) in urls.enumerated() {
//            let operation = DownloadOperation(session: self.session, downloadTaskURL: url, completionHandler: { (localURL, urlResponse, error) in
//                    print("localURL \(localURL)")
//                if error == nil {
//                    DispatchQueue.main.async {
//                        self.progressValue += 1
//                    }
//                }
//            })
//
//            completionOperation.addDependency(operation)
//
//            self.queue.addOperation(operation)
//        }
//
//        self.queue.addOperation(completionOperation)
//    }
//}
//
//
//class DownloadOperation : Operation {
//
//    private var task : URLSessionDownloadTask!
//
//    enum OperationState : Int {
//        case ready
//        case executing
//        case finished
//    }
//
//    // default state is ready (when the operation is created)
//    private var state : OperationState = .ready {
//        willSet {
//            self.willChangeValue(forKey: "isExecuting")
//            self.willChangeValue(forKey: "isFinished")
//        }
//
//        didSet {
//            self.didChangeValue(forKey: "isExecuting")
//            self.didChangeValue(forKey: "isFinished")
//        }
//    }
//
//    override var isReady: Bool { return state == .ready }
//    override var isExecuting: Bool { return state == .executing }
//    override var isFinished: Bool { return state == .finished }
//
//    init(session: URLSession, downloadTaskURL: URL, completionHandler: ((URL?, URLResponse?, Error?) -> Void)?) {
//        super.init()
//
//        // use weak self to prevent retain cycle
//        task = session.downloadTask(with: downloadTaskURL, completionHandler: { [weak self] (localURL, response, error) in
//
//            /*
//             if there is a custom completionHandler defined,
//             pass the result gotten in downloadTask's completionHandler to the
//             custom completionHandler
//             */
//            if let completionHandler = completionHandler {
//                // localURL is the temporary URL the downloaded file is located
//                completionHandler(localURL, response, error)
//            }
//
//            /*
//             set the operation state to finished once
//             the download task is completed or have error
//             */
//            self?.state = .finished
//        })
//    }
//
//    override func start() {
//        /*
//         if the operation or queue got cancelled even
//         before the operation has started, set the
//         operation state to finished and return
//         */
//        if(self.isCancelled) {
//            state = .finished
//            return
//        }
//
//        // set the state to executing
//        state = .executing
//
//        print("downloading \(self.task.originalRequest?.url?.absoluteString ?? "")")
//
//            // start the downloading
//            self.task.resume()
//    }
//
//    override func cancel() {
//        super.cancel()
//
//        // cancel the downloading
//        self.task.cancel()
//    }
//}



/// Manager of asynchronous download `Operation` objects

class DownloadManager: NSObject {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    
    fileprivate var operations = [Int: DownloadOperation]()
    
    /// Serial OperationQueue for downloads
    
    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "download"
        _queue.maxConcurrentOperationCount = 1    // I'd usually use values like 3 or 4 for performance reasons, but OP asked about downloading one at a time
        
        return _queue
    }()
    
    /// Delegate-based `URLSession` for DownloadManager
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    /// Add download
    ///
    /// - parameter URL:  The URL of the file to be downloaded
    ///
    /// - returns:        The DownloadOperation of the operation that was queued
    
    @discardableResult
    func queueDownload(_ url: URL) -> DownloadOperation {
        let operation = DownloadOperation(session: session, url: url)
        operations[operation.task.taskIdentifier] = operation
        queue.addOperation(operation)
        
        return operation
    }
    
    /// Cancel all queued operations
    
    func cancelAll() {
        queue.cancelAllOperations()
    }
    
}

// MARK: URLSessionDownloadDelegate methods

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}

// MARK: URLSessionTaskDelegate methods

extension DownloadManager: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        let key = task.taskIdentifier
        operations[key]?.urlSession(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
    }
    
}

/// Asynchronous Operation subclass for downloading

class DownloadOperation : AsynchronousOperation {
    let task: URLSessionTask
    
    init(session: URLSession, url: URL) {
        task = session.downloadTask(with: url)
        print("start downloading from: \(url)")
        super.init()
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
}

// MARK: NSURLSessionDownloadDelegate methods

extension DownloadOperation: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard
            let httpResponse = downloadTask.response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode
        else {
            // handle invalid return codes however you'd like
            return
        }

        do {
            let manager = FileManager.default
            let destinationURL = try manager
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(downloadTask.originalRequest!.url!.lastPathComponent)
            try? manager.removeItem(at: destinationURL)
            try manager.moveItem(at: location, to: destinationURL)
        } catch {
            print(error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("\(downloadTask.originalRequest!.url!.absoluteString) \(progress)")
    }
}

// MARK: URLSessionTaskDelegate methods

extension DownloadOperation: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        defer { finish() }
        
        if let error = error {
            print(error)
            return
        }
        
        // do whatever you want upon success
    }
    
}



class AsynchronousOperation: Operation {
    
    /// State for this operation.
    
    @objc private enum OperationState: Int {
        case ready
        case executing
        case finished
    }
    
    /// Concurrent queue for synchronizing access to `state`.
    
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".rw.state", attributes: .concurrent)
    
    /// Private backing stored property for `state`.
    
    private var rawState: OperationState = .ready
    
    /// The state of the operation
    
    @objc private dynamic var state: OperationState {
        get { return stateQueue.sync { rawState } }
        set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
    }
    
    // MARK: - Various `Operation` properties
    
    open         override var isReady:        Bool { return state == .ready && super.isReady }
    public final override var isExecuting:    Bool { return state == .executing }
    public final override var isFinished:     Bool { return state == .finished }
    
    // KVO for dependent properties
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }
        
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    // Start
    
    public final override func start() {
        if isCancelled {
            finish()
            return
        }
        
        state = .executing
        
        main()
    }
    
    /// Subclasses must implement this to perform their work and they must not call `super`. The default implementation of this function throws an exception.
    
    open override func main() {
        fatalError("Subclasses must implement `main`.")
    }
    
    /// Call this function to finish an operation that is currently executing
    
    public final func finish() {
        if !isFinished { state = .finished }
    }
}
