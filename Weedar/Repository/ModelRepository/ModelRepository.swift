//
//  ModelRepository.swift
//  Weelar
//
//  Created by vtsyomenko on 31.08.2021.
//

import Foundation

class ModelRepository: BaseRepository {
    static let shared = ModelRepository()
    
    // return product object
    func getModel(id: String, completion: @escaping (Result<Data, ProductRequestError>) -> Void) {
        
        guard let token = token else {
            completion(.failure(.custom(errorMessage: "User is not authorized.")))
            return
        }
        
        guard let url = URL(string: baseURL + "/model/\(id)") else {
            completion(.failure(.custom(errorMessage: "Can't resolve URL endpoint")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "Empty data")))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
