//
//  NSObject+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 20.09.2021.
//

import Foundation

extension NSObject {
    func checkError(byCode errorCode: Int) -> ErrorAPI {
        switch errorCode {
        case 400:
            return .invalidRequest

        case 401:
            return .invalidCredentials

        case 404:
            return .notFound

        default:
            return .unknownError
        }
    }
}
