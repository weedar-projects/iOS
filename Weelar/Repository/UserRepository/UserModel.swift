//
//  UserModel.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 18.08.2021.
//

import Foundation

struct UserResponse: Codable {
    let id: Int
    let name: String?
    let email, phone, passportPhotoLink: String?
    let physicianRecPhotoLink: String?
    let state, createdAt: String
    let enableNotifications: Bool
    let role: Role
    let roleId: Int
}

// MARK: - Role
struct Role: Codable {
    let id: Int
    let code, name: String
}

enum UserRequestError: Error {
    case invalidRequest
    case custom(errorMessage: String)
}

struct UserActiveModel: Codable {
    var statusCode: Int
    var message: String?
    var error: String?
}

struct UserRegisterRequestModel: Codable {
    var email: String
    var password: String
}

struct UserRegisterResponseModel: Codable {
    var statusCode: Int
    var message: [String]?
    var error: String?
}

struct ChangePasswordRequestModel: Codable {
    var oldPassword: String
    var password: String
}

struct ResetPasswordRequestModel: Codable {
    let email: String
}

