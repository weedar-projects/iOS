//
//  LoginRepository.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 03.08.2021.
//

import Foundation

final class LoginRepository: BaseRepository {
    /// API `Login User`
    func login(email: String, password: String, completion: @escaping (Result<LoginResponseModel, ServerError>) -> Void) {
        guard
            let url = URL(string: baseURL + "/auth/login")
        else {
            Logger.log(message: "Can't resolve URL endpoint", event: .error)
            completion(.failure(ServerError(statusCode: 400, message: "Unsupported URL")))
            return
        }

        let body = LoginRequestModel(email: email, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpBody = try? JSONEncoder().encode(body)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(ServerError(statusCode: 400, message: error.localizedDescription)))
                return
            }
            
            guard
                let data = data
            else {
                completion(.failure(ServerError(statusCode: 400, message: "Data not found")))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else {
                completion(.failure(.default))
                return
            }
            
            switch urlResponse.statusCode {
            case 200...299:             guard
                let loginResponse = try? JSONDecoder().decode(LoginResponseModel.self, from: data)
                else {
                    completion(.failure(ServerError(statusCode: 400, message: "Invalid credentials")))
                    return
                }
                
                guard
                    !loginResponse.accessToken.isEmpty
                else {
                    completion(.failure(ServerError(statusCode: 400, message: "Invalid credentials")))
                    return
                }
                
                completion(.success(loginResponse))
                
            default:
                let error = try? JSONDecoder().decode(ServerError.self, from: data)
                completion(.failure(ServerError(statusCode: urlResponse.statusCode, message: error?.message ?? "Unknown error")))
            }
            
//            guard
//                let urlResponse = response as? HTTPURLResponse, (200...299).contains(urlResponse.statusCode)
//            else {
//                completion(.failure((response as? HTTPURLResponse)?.statusCode == 404 ? .neededSignUp : .invalidCredentials))
//                return
//            }
//
//            guard
//                let loginResponse = try? JSONDecoder().decode(LoginResponseModel.self, from: data)
//            else {
//                completion(.failure(.invalidCredentials))
//                return
//            }
//            
//            guard
//                !loginResponse.accessToken.isEmpty
//            else {
//                completion(.failure(.noToken))
//                return
//            }
//
//            completion(.success(loginResponse))
        }
        .resume()
    }
}
