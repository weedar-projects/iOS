//
//  UserRepository.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 18.08.2021.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserRepository: BaseRepository {
    
    static var shared = UserRepository()
    
    private var uploadProgressCompletion: ((Float) -> Void)?
    
    func getUserInfo(userId: Int, completion: @escaping (Result<UserResponse, UserRequestError>) -> Void) {
        let url = baseURL + "/user/\(userId)"
        
        completeHeaders()
        
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: UserResponse.self) { response in
              guard let user = response.value else {
                completion(.failure(.custom(errorMessage: "Empty data")))
                return
              }
              completion(.success(user))
        }
    }
    
    func sendActive(completion: @escaping (Result<Bool, UserRequestError>) -> Void) {
        guard let token = token else {
            completion(.failure(.custom(errorMessage: "User is not authorized.")))
            return
        }

        guard let url = URL(string: baseURL + "/user/active") else {
            completion(.failure(.custom(errorMessage: "Can't resolve URL endpoint")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "Empty data")))
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(.failure(.invalidRequest))
               return
            }

            completion(.success(true))
        }.resume()
    }
    
    func verifyPassport(passportImage: UIImage?,
                        physImage: UIImage?,
                        finishRegistration: Bool  = false,
                        progress: @escaping (Float) -> Void,
                        completion: @escaping (Result<Bool, OrderRequestError>) -> Void) {

        progress(0.01)
        
        guard
            let token = token,
            let id = UserDefaultsService().get(fromKey: .user) as? Int
        else {
            completion(.failure(OrderRequestError(message: "User is not authorized.")))
            return
        }

        guard let url = URL(string: baseURL + "/user/\(id)/verifyPassport") else {
            completion(.failure(OrderRequestError(message: "Can't resolve URL endpoint")))
            return
        }
        
      guard let passportJpeg = passportImage?.jpegData(compressionQuality: 0.7) else {
            completion(.failure(OrderRequestError(message: "Couldn't get image data")))
            return
        }
        let boundary = UUID().uuidString

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        data.append().setValue(finishRegistration, forHTTPHeaderField: "registrationFinish")
        var data = Data()
        

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"passportPhoto\"; filename=\"passportPhoto\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
        data.append(passportJpeg)
        
        print(data.count)
        
      if let physJpeg = physImage?.jpegData(compressionQuality: 0.7) {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"physicianRecPhoto\"; filename=\"physicianRecPhoto\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
            data.append(physJpeg)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        } else {
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        }
        
        request.httpBody = data
        progress(0.1)
        
        self.uploadProgressCompletion = progress
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        session.uploadTask(with: request, from: data, completionHandler: { responseData, response, error in
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(.failure(OrderRequestError(message: "Invalid Request")))
               return
            }
            completion(.success(true))
        }).resume()
//        URLSession.shared.dataTask(with: request, completionHandler: { responseData, response, error in
//            print(String(data: responseData!, encoding: .utf8))
//            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                completion(.failure(.invalidRequest))
//               return
//            }
//            completion(.success(true))
//        }).resume()
    }
    
    func verifyPhone(phone: String, completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        print("token = \(token) , userid = \(UserDefaultsService().get(fromKey: .user) as? Int)")
        
        guard
            let token = token,
            let id = UserDefaultsService().get(fromKey: .user) as? Int
        else {
            completion(.failure(.custom(errorMessage: "User is not authorized.")))
            return
        }
        
        
        
        guard let url = URL(string: baseURL + "/user/\(id)/verifyPhone") else {
            completion(.failure(.custom(errorMessage: "Can't resolve URL endpoint")))
            return
        }

        let body = [
            "phone": phone
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(body)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                completion(.success(true))
            }
            else {
                // todo read error
                completion(.failure(.custom(errorMessage: "Password is not in format or user with email already exist.")))
            }
        }
        .resume()
    }
    
    /// API `Update FCM token`
    func token(fcmToken: String, completion: @escaping (Result<Bool, ErrorAPI>) -> Void) {
        guard
            let token = token,
            let id = UserDefaultsService().get(fromKey: .user) as? Int
        else {
            completion(.failure(.userNotAuthorized))
            return
        }
        
        guard
            let url = URL(string: baseURL + "/user/\(id)/token")
        else {
            completion(.failure(.unsuppotedURL))
            return
        }

        let body = ["firebaseToken": fcmToken]
        print("tokenfcm: \(fcmToken)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(body)
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard
                error == nil
            else {
                completion(.failure(.transportError))
                return
            }

            guard
                data != nil
            else {
                completion(.failure(.notFound))
                return
            }

            guard
                let urlResponse = response as? HTTPURLResponse, (200...299).contains(urlResponse.statusCode)
            else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(true))
        }
        .resume()
    }
    
    func updatePassword(_ oldPassword: String,
                        newPassword: String,
                        completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        guard
            let token = token,
            let id = UserDefaultsService().get(fromKey: .user) as? Int,
            let url = URL(string: baseURL + "/user/\(id)/updatePassword")
        else {
            completion(.failure(.custom(errorMessage: "Can't resolve URL endpoint")))
            return
        }
        
        let body = ChangePasswordRequestModel(oldPassword: oldPassword, password: newPassword)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.httpBody = try? JSONEncoder().encode(body)
        request.timeoutInterval = 15
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
                completion(.success(true))
            } else {
                // todo read error
                completion(.failure(.custom(errorMessage: "")))
            }
        }
        .resume()
    }
   
    /// API `Reset Password`
    func resetPassword(byEmail email: String,
                       completion: @escaping (Result<Bool, ErrorAPI>) -> Void) {
        guard
            let url = URL(string: baseURL + "/user/resetPassword")
        else {
            completion(.failure(.unsuppotedURL))
            return
        }
        
        let body = ResetPasswordRequestModel(email: email)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.httpBody = try? JSONEncoder().encode(body)
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
            
            completion(.success(true))
        }
        .resume()
    }

    /// API `User Enable/Disable Remote Push Notifications`
    func userPushNotificationChange(_ isEnable: Bool,
                                    completion: @escaping (Result<Bool, ErrorAPI>) -> Void) {
        guard
            let token = token,
            let id = UserDefaultsService().get(fromKey: .user) as? Int,
            let url = URL(string: baseURL + "/user/\(id)/settings")
        else {
            Logger.log(message: "Can't resolve URL endpoint", event: .error)
            completion(.failure(.unsuppotedURL))
            return
        }
        
        let body = ["enableNotifications": isEnable]
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.httpBody = try? JSONEncoder().encode(body)
        request.timeoutInterval = 15
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard
                error == nil
            else {
                completion(.failure(.transportError))
                return
            }

            guard
                data != nil
            else {
                completion(.failure(.notFound))
                return
            }

            guard
                let urlResponse = response as? HTTPURLResponse, (200...299).contains(urlResponse.statusCode)
            else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            UserDefaultsService().set(value: isEnable, forKey: .fcmEnabled)
            completion(.success(true))
        }
        .resume()
    }
    
    
    func userRegister(email: String, password: String, comletion: @escaping (Result<Bool, ServerError>) -> Void){
        let url = baseURL.appending("/user/register")
        
        let params = ["email" : email,
                      "password" : password]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
            let statusCode = response.response?.statusCode ?? 0
                print("\n\n-------API-------\(statusCode)\n")

            switch response.result{
            case let .success(data):
                guard let data = data else { return
                }
                let json = JSON(data)
                print(json)
                switch (response.response?.statusCode ?? 0){
                case 200...299:
                    comletion(.success(true))
                default:
                    if json.isEmpty{
                        let message = String(data: data, encoding: String.Encoding.utf8)
                        comletion(.failure(ServerError(statusCode: response.response?.statusCode ?? 0, message: message ?? "")))
                    }else{
                        comletion(.failure(ServerError(statusCode: json["statusCode"].intValue, message: json["message"].arrayValue.first?.stringValue ?? "")))
                        print(json["statusCode"].intValue)
                        print(json["message"].arrayValue.first?.stringValue ?? "")
                    }
                }
            case let .failure(error):
                print(response.response?.statusCode ?? 0)
                print(error.localizedDescription)
                comletion(.failure(ServerError(statusCode: response.response?.statusCode ?? 0, message: error.localizedDescription)))
        }
            
        }
    }
    /// API `User Register`
    func register(email: String, password: String, completion: @escaping (Result<Bool, ServerError>) -> Void) {
        guard
            let url = URL(string: baseURL + "/user/register")
        else {
            Logger.log(message: "Can't resolve URL endpoint", event: .error)
            completion(.failure(.default))
            return
        }

        let body = UserRegisterRequestModel(email: email, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.httpBody = try? JSONEncoder().encode(body)
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard
                error == nil
            else {
                Logger.log(message: error!.localizedDescription, event: .error)
                completion(.failure(.default))
                return
            }

            guard
                let data = data
            else {
                Logger.log(message: "Data is empty.", event: .error)
                completion(.failure(.default))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else {
                completion(.failure(.default))
                return
            }
            
            switch urlResponse.statusCode {
            case 200...299: completion(.success(true))
            default:
                let message = String(data: data, encoding: String.Encoding.utf8)
                completion(.failure(ServerError(statusCode: urlResponse.statusCode, message: message ?? "Unknown error")))
            }
        }
        .resume()
    }

    // return product object
    func deletePassportPhoto(physRec: Bool, id: Int, completion: @escaping (Result<Data, ProductRequestError>) -> Void) {
        
        struct PassportRequestModel: Codable {
            var passportPhotoLink, physicianRecPhotoLink: Bool?
        }
        
        guard let token = token else {
            completion(.failure(.custom(errorMessage: "User is not authorized.")))
            return
        }
        
        guard let url = URL(string: baseURL + "/user/\(id)/passportPhoto") else {
            completion(.failure(.custom(errorMessage: "Can't resolve URL endpoint")))
            return
        }

        
        let body = physRec ? PassportRequestModel(passportPhotoLink: false, physicianRecPhotoLink: true) : PassportRequestModel(passportPhotoLink: true, physicianRecPhotoLink: false)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "Empty data")))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}

extension UserRepository: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        uploadProgressCompletion?(Float(totalBytesSent)/Float(totalBytesExpectedToSend) * 0.8 + 0.1)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            uploadProgressCompletion?(1)
        }
    }
}
