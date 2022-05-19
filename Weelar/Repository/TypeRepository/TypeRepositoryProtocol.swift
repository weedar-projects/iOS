//
//  TypeRepositoryProtocol.swift
//  Weelar
//
//  Created by AnyMac Store on 14.09.2021.
//

import Foundation

protocol TypeRepositoryProtocol {
    func getTypes(completion: @escaping (Result<[TypeResponseModel], OrderRequestError>) -> Void)
}
