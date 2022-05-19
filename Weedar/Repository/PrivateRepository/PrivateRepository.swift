//
//  PrivateRepository.swift
//  Weelar
//
//  Created by vtsyomenko on 27.09.2021.
//

import Combine
import Foundation
import Alamofire

final class PrivateRepository: BaseRepository {
    static let shared = PrivateRepository()
    
    func getPrivateImage(_ fileId: String, completion: @escaping (Result<UIImage, AFError>) -> Void) {
        let url = baseURL + "/private/img/\(fileId)"
        print(fileId)
        completeHeaders()
        
        AF.request(url, headers: headers) { $0.timeoutInterval = 10 }
            .validate()
            .responseData { response in
                guard let data = response.value else {
                    completion(.failure(response.error!))
                    return
                }
                let image = UIImage(data: data)
                completion(.success(image!))
            }
    }
    
    func imagePublisher(_ fileId: String) -> AnyPublisher<Result<UIImage, AFError>, Never> {
        let url = baseURL + "/private/img/\(fileId)"
        completeHeaders()
        
        return AF.request(url, headers: headers)
            .validate()
            .publishDecodable(type: Data.self, queue: .main)
            .map { responseData -> Result<UIImage, AFError> in
                guard let data = responseData.value, let image = UIImage(data: data) else {
                    return Result.failure(AFError.sessionTaskFailed(error: responseData.error ?? ErrorAPI.invalidResponse))
                }
                return .success(image)
            }
            .eraseToAnyPublisher()
    }

}
