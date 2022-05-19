//
//  ProductRepository.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 10.08.2021.
//

import Foundation

class ProductRepository: BaseRepository {
    // MARK: - Properties
    static let shared = ProductRepository()
    
    
    // MARK: - Initialization
    private override init() { }
    
    
    // MARK: - Custom functions
    /// API `Get Product`
    func getProduct(id: String, completion: @escaping (Result<Product, ProductRequestError>) -> Void) {
        
        guard let token = token else {
            completion(.failure(.custom(errorMessage: "User is not authorized.")))
            return
        }
        
        guard let url = URL(string: baseURL + "/product/\(id)") else {
            completion(.failure(.custom(errorMessage: "Can't resolve URL endpoint")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "Empty data")))
                return
            }

            guard let productResponse = try? JSONDecoder().decode(Product.self, from: data) else {
                completion(.failure(.invalidRequest))
                return
            }

            completion(.success(productResponse))
        }.resume()
    }
    
    /// API `Get Products`
    func getProducts(withParameters parameters: FiltersRequestModel, completion: @escaping (Result<[Product], ErrorAPI>) -> Void) {
        guard
            let token = token,
            var url = URL(string: baseURL + "/product")
        else {
            Logger.log(message: "Can't resolve URL endpoint", event: .error)
            completion(.failure(.unsuppotedURL))
            return
        }
        
        // Add Price parameters
        if let priceFrom = parameters.priceFrom {
            url.appendQueryItem(name: "priceFrom", value: "\(priceFrom)")
        }

        if let priceTo = parameters.priceTo {
            url.appendQueryItem(name: "priceTo", value: "\(priceTo)")
        }

        // Add Brands parameters
        if let brands = parameters.brands, brands.count > 0 {
            brands.forEach({ url.appendQueryItem(name: "brand", value: "\($0)") })
        }
        
        // Add Effects parameters
        if let effects = parameters.effects, effects.count > 0 {
            effects.forEach({ url.appendQueryItem(name: "effect", value: "\($0)") })
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = MethodHTTP.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        Logger.log(message: "URL: \(url.absoluteString)", event: .debug)
       
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
                let responseResult = try? JSONDecoder().decode([Product].self, from: data)
            else {
                completion(.failure(ErrorAPI.invalidResponse))
                return
            }

            completion(.success(responseResult))
        }
        .resume()
    }
}
