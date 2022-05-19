//
//  SupportModel.swift
//  Weelar
//
//  Created by vtsyomenko on 25.08.2021.
//

import Foundation

struct SupportMessage: Codable {
    let title: String
    let message:String
}

struct SupportResponse: Codable {
    let id: Int
    let title, message: String
    let user: UserInformation?
}

struct UserInformation: Codable {
    let email, phone: String
}
