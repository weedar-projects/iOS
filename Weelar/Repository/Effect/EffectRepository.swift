//
//  EffectRepository.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 06.10.2021.
//

import Foundation

protocol EffectRepositoryType {
    func getEffects(completion: @escaping (Result<[Product.Effect], ErrorAPI>) -> Void)
}

final class EffectRepository: BaseRepository, EffectRepositoryType {
    // MARK: - Properties
    static let shared = EffectRepository()
    
    
    // MARK: - Initialization
    private override init() { }
    
    
    // MARK: - Custom functions
    /// API `Get Effects`
    func getEffects(completion: @escaping (Result<[Product.Effect], ErrorAPI>) -> Void) {
        guard
            let token = token,
            let url = URL(string: baseURL + "/effect")
        else {
            Logger.log(message: "Can't resolve URL endpoint", event: .error)
            completion(.failure(.unsuppotedURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = MethodHTTP.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard
                error == nil
            else {
                Logger.log(message: error!.localizedDescription, event: .error)
                completion(.failure(.transportError))
                return
            }

            guard
                data != nil
            else {
                Logger.log(message: "Data is empty.", event: .error)
                completion(.failure(.notFound))
                return
            }

            guard
                let urlResponse = response as? HTTPURLResponse, (200...299).contains(urlResponse.statusCode)
            else {
                completion(.failure(.invalidCredentials))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let data = data,
                let responseResult = try? JSONDecoder().decode([Product.Effect].self, from: data)
            else {
                completion(.failure(ErrorAPI.invalidResponse))
                return
            }

            completion(.success(responseResult))
        }
        .resume()
    }
}
