//
//  SupportRepository.swift
//  Weelar
//
//  Created by vtsyomenko on 25.08.2021.
//

import Foundation

class SupportRepository: BaseRepository {
    
    static var shared = SupportRepository()
    
    func sendSupportMessage(_ message: SupportMessage, completion: @escaping (Result<SupportResponse, OrderRequestError>) -> Void) {
        
        guard let token = token else {
            completion(.failure(OrderRequestError(message: "User is not authorized.")))
            return
        }
        
        guard let url = URL(string: baseURL + "/support") else {
            completion(.failure(OrderRequestError(message: "Can't resolve URL endpoint")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(message)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(.failure(OrderRequestError(message: "Empty data")))
                    return
                }
                guard let response = try? JSONDecoder().decode(SupportResponse.self, from: data) else {
                    completion(.failure(OrderRequestError(message: "Can't decode response")))
                    return
                }
                
                completion(.success(response))
            }
        }.resume()
    }
}
