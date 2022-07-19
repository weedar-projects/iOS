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
    
    var accessToken : String?  { return KeychainService.loadPassword(serviceKey: .accessToken) }
    var refreshToken : String?  { return KeychainService.loadPassword(serviceKey: .refreshToken) }

    func request(url: String = "",
                 endPoint: String = "",
                 rout: Routs = .empty,
                 method: HTTPMethod = .get,
                 parameters: [String: Any] = [:],
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: HTTPHeaders = [:],
                 completion: @escaping (Result<JSON,APIError>) -> Void ){
        
        var reqUrl: URL?
        
        if !url.isEmpty{
            reqUrl = URL(string: url)!
        }
        
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

        if let token = accessToken {
            heads.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        heads.add(name: "Content-Type", value: "application/json")
        
        guard let reqUrl = reqUrl else {
            print("URL IS EMPTY")
            return
        }
        
        let interceptor = APIRequestInterceptor()
        
        AF.request(reqUrl,
                   method: method,
                   parameters: parameters,
                   encoding: encoding,
                   headers: heads,
                   interceptor: interceptor)
        .customValidation()
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
                        let error = APIError(statusCode: json["statusCode"].intValue,
                                              message: json["message"].arrayValue.first?.stringValue ?? "")
                        
                        if error.message.isEmpty{
                            let stringError = APIError(statusCode: json["statusCode"].intValue,
                                                  message: json["message"].stringValue)
                            completion(.failure(stringError))
                        }else{
                            completion(.failure(error))
                        }
                        
                        print("ERROR: \n\(error)")
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

        if let token = accessToken {
            heads.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        heads.add(name: "Content-Type", value: "application/json")
        
        guard let reqUrl = reqUrl else {
            return
        }
        let interceptor = APIRequestInterceptor()
        
        AF.request(reqUrl, method: method,
                   parameters: parameters,
                   encoding: encoding,
                   headers: heads,
                   interceptor: interceptor)
        .customValidation()
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
//    enum VersionError: Error {
//        case invalidResponse, invalidBundleInfo
//    }
//
    
    
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


class APIRequestInterceptor: RequestInterceptor {
    
    var retryLimit = 2
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        guard let token = KeychainService.loadPassword(serviceKey: .accessToken) else {
            completion(.success(urlRequest))
            return
        }
        let bearerToken = "Bearer \(token)"
        request.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        print("\nadapted; token added to the header field is: \(bearerToken)\n")
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < retryLimit else {
            completion(.doNotRetry)
            return
        }
        print("\nretried; retry count: \(request.retryCount)\n")
        tokenRefresh { isSuccess in
            isSuccess ? completion(.retry) : completion(.doNotRetry)
        }
    }
    
//    func refreshToken(completion: @escaping (_ isSuccess: Bool) -> Void) {
//        guard let apiKey = UserDefaultsManager.shared.getUserCredentials().apiKey,
//            let secretKey = UserDefaultsManager.shared.getUserCredentials().secretKey else { return }
//
//        let parameters = ["grant_type": "client_credentials", "client_id": apiKey, "client_secret": secretKey]
//
//        AF.request(authorize, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
//            if let data = response.data, let token = (try? JSONSerialization.jsonObject(with: data, options: [])
//                as? [String: Any])?["access_token"] as? String {
//                UserDefaultsManager.shared.setToken(token: token)
//                print("\nRefresh token completed successfully. New token is: \(token)\n")
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//    }
    
    func tokenRefresh(completion: @escaping (_ isSuccess: Bool) -> Void){
        guard let refreshToken = KeychainService.loadPassword(serviceKey: .refreshToken) else {
            return
        }
        print("TOKEN TO UPDATE refreshToken: \(refreshToken)")
        let params = [
            "refreshToken" : refreshToken
        ]
        
        let url = URL(string: PKSettingsBundleHelper.shared.currentEnvironment.baseUrl.appending(Routs.refreshToken.rawValue))!
        
        AF.request(url, method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default)
            .response {  result in
                switch result.result{
                case let .success(data):
                    guard let data = data else { return }
                    
                    let json = JSON(data)
                    print(json)
                    let accessToken = json["accessToken"].stringValue
                    let refreshToken = json["refreshToken"].stringValue
                    print("accessToken: \(accessToken)")
                    print("refreshToken: \(refreshToken)")
                    
                    if !accessToken.isEmpty, !refreshToken.isEmpty{
                        KeychainService.updatePassword(accessToken, serviceKey: .accessToken)
                        KeychainService.updatePassword(refreshToken, serviceKey: .refreshToken)
                    }
                    
                    completion(true)
                case let .failure(error):
                    print("ERROR TO REFRESH TOKEN: \(error.localizedDescription)")
                    completion(false)
                }

            }
    }
}


extension DataRequest {
    public func customValidation() -> Self {
        
        return validate { request,response,data in
            do {
                let statusCode = response.statusCode
                if statusCode != 401{
                    print("STATUS CODE NOT 401")
                    return .success({}())
                }else{
                    print("STATUS CODE 401")
                    let reason:AFError.ResponseValidationFailureReason = .unacceptableStatusCode(code: response.statusCode)
                    return .failure(AFError.responseValidationFailed(reason: reason))
                }
            } catch let error {
                print("Json serialization error \(error)")
                let reason:AFError.ResponseValidationFailureReason = .unacceptableStatusCode(code: response.statusCode)
                return .failure(AFError.responseValidationFailed(reason: reason))
                
            }
        }
    }
}
