//
//  TypeRepository.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 14.09.2021.
//

import Alamofire

final class TypeRepository: BaseRepository, TypeRepositoryProtocol {

    func getTypes(completion: @escaping (Result<[TypeResponseModel], OrderRequestError>) -> Void) {
        let url = baseURL + "/type"

        completeHeaders()
        
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [TypeResponseModel].self) { response in
              guard let types = response.value else {
                completion(.failure(OrderRequestError(message: "Empty data")))
                return
              }
              completion(.success(types))
        }
    }
}
