//
//  OrderRepository.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 10.08.2021.
//

import Foundation
import Alamofire
import SwiftyJSON

final class OrderRepository: BaseRepository, OrderRepositoryProtocol {

    
    static let shared = OrderRepository()

    func makeOrder(data: OrderRequestModel, completion: @escaping (Result<OrderResponseModel, OrderRequestError>) -> Void) {

        completeHeaders()

        
        print("data: \(data)")
        guard let request = completeRequest(method: "POST",
                                            endpoint: "/order",
                                            data: data) else {
            completion(.failure(OrderRequestError(message: "Can't compose request")))
            return
        }

        AF.request(request)
            .validate()
            .response(completionHandler: { response in
                switch response.result{
                case let .success(data):
                    guard let data = data else { return
                        completion(.failure(OrderRequestError(message: response.error.debugDescription ?? "error to get data")))
                    }
                    let json = JSON(data)
                    let order = OrderResponseModel(json: json)
                    completion(.success(order))
                case let .failure(error):
                    let errorMessage = String(data: response.data ?? Data(), encoding: String.Encoding.utf8)
                    print("Make order error \(error)")
                    completion(.failure(OrderRequestError(message: errorMessage ?? "Unknown Error")))
                }
            })
//            .responseDecodable(of: OrderResponseModel.self) { response in
//                switch response.result {
//                case .success(let order) :
//                    completion(.success(order))
//                case .failure(let error) :
//                    let errorMessage = String(data: response.data!, encoding: String.Encoding.utf8)
//
//                    print("Make order error \(error)")
//                    completion(.failure(OrderRequestError(message: errorMessage ?? "Unknown Error")))
//
//                }
//        }
    }
    
    func confirmOrder(id: Int, completion: @escaping (Result<Bool, OrderRequestError>) -> Void) {
        let url = baseURL + "/order/\(id)/confirm"

        completeHeaders()
        
        AF.request(url, method: .put, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success:
                    completion(.failure(OrderRequestError(message: String(data: response.data!, encoding: String.Encoding.utf8) ?? "Unknown Error")))
                    
                case .failure(let error):
                    completion(.success(true))
            }
        }
    }
    

    
    func getOrders(userId id: Int, completion: @escaping (Result<[OrderResponseModel], OrderRequestError>) -> Void) {
        let url = baseURL + "/order/user/\(id)"

        completeHeaders()

        AF.request(url, headers: headers)
            .validate()
            .response(completionHandler: { response in
                guard let data = response.data else {
                    completion(.failure(OrderRequestError(message: "Empty data")))
                    return
                    
                }
                let json = JSON(data)
                completion(.success(json.arrayValue.map{OrderResponseModel(json: $0)}))
            })
    }

    func cancelOrder(orderId id: Int, completion: @escaping (Result<String, OrderRequestError>) -> Void) {
        let url = baseURL + "/order/\(id)/cancel"

        completeHeaders()

        AF.request(url, method: .put, headers: headers)
            .validate()
            .responseJSON { response in

                switch response.result {
                case .success:
                    print(response.response)
                    break
                case .failure(let error):
                    print(error)
                }
            }
    }

    func getOrderDetails(orderId: Int, completion: @escaping (Result<[OrderDetailOLD], OrderRequestError>) -> Void) {
        guard orderId != 0 else { return }

        let url = baseURL + "/orderDetail/order/\(orderId)"
        
        completeHeaders()
        
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [OrderDetailOLD].self) { response in
              guard let orderDetails = response.value else {
                completion(.failure(OrderRequestError(message: "Can't decode order response")))
                return
              }
              completion(.success(orderDetails))
        }
    }
    
    // Deprecated:
    
//    func makeOrder2(data: OrderRequestModel, completion: @escaping (Result<OrderResponseModel, OrderRequestError>) -> Void) {
//        guard let token = token else {
//            completion(.failure(OrderRequestError(message: "User is not authorized.")))
//            return
//        }
//
//        guard let url = URL(string: baseURL + "/order") else {
//            completion(.failure(OrderRequestError(message: "Can't resolve URL endpoint")))
//            return
//        }
//
//        let body = data
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "accept")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.httpBody = try? JSONEncoder().encode(body)
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//
//            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                completion(.failure(OrderRequestError(message: "Error URL Code")))
//               return
//            }
//
//            guard let data = data, error == nil else {
//                completion(.failure(OrderRequestError(message: "Empty data")))
//                return
//            }
//
//
//
//            completion(.success(orderResponse))
//        }.resume()
//    }
    
//    func confirmOrder2(id: Int, completion: @escaping (Result<Bool, OrderRequestError>) -> Void) {
//        guard let token = token else {
//            completion(.failure(OrderRequestError(message: "User is not authorized.")))
//            return
//        }
//
//        guard let url = URL(string: baseURL + "/order/\(id)/confirm") else {
//            completion(.failure(OrderRequestError(message: "Can't resolve URL endpoint")))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.setValue("*/*", forHTTPHeaderField: "accept")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.timeoutInterval = 15
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//
//            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                completion(.failure(OrderRequestError(message: "Invalid request")))
//               return
//            }
//            print(response)
//            completion(.success(true))
//        }.resume()
//    }
    
    func getOrders2(userId id: Int, completion: @escaping (Result<[OrderResponseModel], OrderRequestError>) -> Void) {

        guard let token = token else {
            completion(.failure(OrderRequestError(message: "User is not authorized.")))
            return
        }
        
        guard let url = URL(string: baseURL + "/order/user/\(id)") else {
            completion(.failure(OrderRequestError(message: "Can't resolve URL endpoint")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(.failure(OrderRequestError(message: "Empty data")))
                    return
                }

                
//                completion(.success(productResponse))
            }
        }.resume()
    }
    
    func getOrderDetails2(orderId: Int, completion: @escaping (Result<[OrderDetailOLD], OrderRequestError>) -> Void) {
        guard orderId != 0 else { return }
        
        guard let token = token else {
            completion(.failure(OrderRequestError(message: "User is not authorized.")))
            return
        }
        
        guard let url = URL(string: baseURL + "/orderDetail/order/\(orderId)") else {
            completion(.failure(OrderRequestError(message: "Can't resolve URL endpoint")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(.failure(OrderRequestError(message: "Empty data")))
                    return
                }
                
                guard let productResponse = try? JSONDecoder().decode([OrderDetailOLD].self, from: data) else {
                    completion(.failure(OrderRequestError(message: "Can't decode order response")))
                    return
                }
                
                completion(.success(productResponse))
            }
        }.resume()
    }
}
