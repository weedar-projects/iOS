//
//  LoginModel.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 03.08.2021.
//

import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
    case custom(errorMessage: String)
}

struct LoginRequestModel: Codable {
    var email: String
    var password: String
}

struct LoginResponseModel: Codable {
    var id: Int
    var email, role: String
    var state: String
    var phone: String?
    var accessToken: String
}
