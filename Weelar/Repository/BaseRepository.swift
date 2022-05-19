//
//  BaseRepository.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 10.08.2021.
//

import Foundation
import Alamofire
//
//var baseVar: String {
//  get {
//    goingProd ? "https://api-prod.weelar.com" : "https://dev.api.weelar.engenious.io"
//  }
//}

let goingProd = true

class BaseRepository: NSObject {
      let baseURL = PKSettingsBundleHelper.shared.currentEnvironment.baseUrl
//  let baseURL = "https://api-prod.weelar.com"
  
  var token : String?  { return KeychainService.loadPassword(serviceKey: .accessToken) }
    
  var headers : HTTPHeaders = [:]
  
  func addBearer() {
    guard let token = token else {
      return
    }
    headers["Authorization"] = "Bearer \(token)"
    print(headers)
  }
  
  func completeHeaders() {
    guard let token = token else {
      return
    }
    
    headers.add(name: "Authorization", value: "Bearer \(token)")
    headers.add(name: "Content-Type", value: "application/json")
  }
  
  func completeRequest<T : Encodable>(method: String, endpoint: String, data: T) -> URLRequest? {
    completeHeaders()
    
    guard let url = URL(string: baseURL + endpoint) else {
      return nil
    }
    
    var request = URLRequest(url: url)
    
    for header in headers {
      request.setValue(header.value as String, forHTTPHeaderField: header.name)
    }
    request.httpMethod = method
    request.httpBody = try? JSONEncoder().encode(data)
    
    return request
  }
}
