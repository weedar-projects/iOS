//
//  API.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 30.03.2022.
//

import Alamofire
import SwiftyJSON
import Foundation


struct APIError: Error {
    var statusCode: Int
    var message: String
}

class API{
    
    static let shared = API()
    
    private var baseURL: String = PKSettingsBundleHelper.shared.currentEnvironment.baseUrl
    
    private var token : String?  { return KeychainService.loadPassword(serviceKey: .accessToken) }
    
    func request(endPoint: String = "", rout: Routs = .empty,
                 method: HTTPMethod = .get,
                 parameters: [String: Any] = [:],
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: HTTPHeaders = [:],
                 completion: @escaping (Result<JSON,APIError>) -> Void ){
        
        var reqUrl: URL?
        
        //add url
        if !endPoint.isEmpty {
            reqUrl = URL(string: baseURL)!.appendingPathComponent(endPoint)
        }
        
        if rout != .empty{
            reqUrl = URL(string: baseURL)!.appendingPathComponent(rout.rawValue)
        }
        
        //add headers
        var heads: HTTPHeaders = [:]
       
        headers.forEach({heads.add(name: $0.name, value: $0.value)})

        if let token = token {
            heads.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        heads.add(name: "Content-Type", value: "application/json")
        
        guard let reqUrl = reqUrl else {
            return
        }
        
        AF.request(reqUrl, method: method,
                   parameters: parameters,
                   encoding: encoding,
                   headers: heads)
        { $0.timeoutInterval = 120 }
        
        .response { response in
            let statusCode = response.response?.statusCode ?? 0
                print("\n\n-------API-------\n\(reqUrl)  \(statusCode)\n")
                print("----------\nHeaders: \n\(heads)\n----------\n")
                print("----------\nParams: \n\(parameters)\n----------\n")
                
            switch response.result {
            case let .success(data):
                guard let data = data else {
                    print("ERROR: \nNot DATA")
                    return  completion(.failure(APIError(statusCode: statusCode,
                                                         message: "Not data")))
                }
                
                let json = JSON(data)
                
                switch (statusCode){
                case 200...299:
                    print("JSON: \n\(json)")
                    completion(.success(json))
                default:
                    if json.isEmpty{
                        let message = String(data: data, encoding: String.Encoding.utf8)
                        
                        print("ERROR: \n\(message)")
                        completion(.failure(APIError(statusCode: statusCode,
                                                     message: message ?? "")))
                    }else{
                        completion(.failure(APIError(statusCode: json["statusCode"].intValue,
                                                     message: json["message"].arrayValue.first?.stringValue ?? "")))
                    }
                }
                
            case let .failure(error):
                
                print("ERROR: \n\(error.failureReason ?? "")")
                completion(.failure(APIError(statusCode: statusCode,
                                             message: error.failureReason ?? "")))
            }
                
                print("\n-------API-------\n\n")
        }
    }
    
    func requestData(endPoint: String = "",
                     rout: Routs = .empty,
                     method: HTTPMethod = .get,
                     parameters: [String: Any] = [:],
                     encoding: ParameterEncoding = URLEncoding.default,
                     headers: HTTPHeaders = [:],
                     completion: @escaping (Result<Data,APIError>) -> Void) {
        var reqUrl: URL?
        
        //add url
        if !endPoint.isEmpty {
            reqUrl = URL(string: baseURL)!.appendingPathComponent(endPoint)
        }
        
        if rout != .empty{
            reqUrl = URL(string: baseURL)!.appendingPathComponent(rout.rawValue)
        }
        
        //add headers
        var heads: HTTPHeaders = [:]
       
        headers.forEach({heads.add(name: $0.name, value: $0.value)})

        if let token = token {
            heads.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        heads.add(name: "Content-Type", value: "application/json")
        
        guard let reqUrl = reqUrl else {
            return
        }
        
        AF.request(reqUrl, method: method,
                   parameters: parameters,
                   encoding: encoding,
                   headers: heads)
            .response { response in
            
            let statusCode = response.response?.statusCode ?? 0
                
                print("\n\n-------API-------\n\(reqUrl)  \(statusCode)\n")
                print("----------\nHeaders: \n\(heads)\n----------\n")
                print("----------\nParams: \n\(parameters)\n----------\n")
                
            switch response.result {
            case let .success(data):
                guard let data = data else {
                    print("ERROR: \nNot DATA")
                    return  completion(.failure(APIError(statusCode: statusCode,
                                                         message: "Not data")))
                }
                switch (statusCode){
                case 200...299:
                    completion(.success(data))
                default:
                    completion(.failure(APIError(statusCode: statusCode,
                                                 message: "Data Error")))
                }
                
            case let .failure(error):
                print("ERROR: \n\(error.localizedDescription)")
                completion(.failure(APIError(statusCode: statusCode,
                                             message: error.localizedDescription)))
            }
        }
    }
    
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
//MARK: CHECK VERSION FROM APPSTORE
//    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
//        guard let info = Bundle.main.infoDictionary,
//            let currentVersion = info["CFBundleShortVersionString"] as? String,
//            let identifier = info["CFBundleIdentifier"] as? String,
//            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
//                throw VersionError.invalidBundleInfo
//        }
//
//        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData)
//
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            do {
//                if let error = error { throw error }
//
//                guard let data = data else { throw VersionError.invalidResponse }
//
//                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
//
//                guard let result = (json?["results"] as? [Any])?.first as? [String: Any],
//                      let lastVersion = result["version"] as? String else {
//                    throw VersionError.invalidResponse
//                }
//
//                self.request(rout: .checkArea) { result in
//                    switch result{
//                    case let .success(json):
//                        completion(lastVersion == "", nil)
//                        print("lastVersion: \(lastVersion)  currentVersion \(currentVersion)")
//                    case let .failure(error):
//                        completion(nil, error)
//                    }
//                }
//            } catch {
//                completion(nil, error)
//            }
//        }
//        task.resume()
//        return task
//    }
}
