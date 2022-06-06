//
//  Enums.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 15.09.2021.
//

import SwiftUI

enum DateFormatType: String {
    /// "15/09/2021 37:12:56"
    case long = "dd/MM/yyyy HH:mm:ss"
    
    /// "15/09/2021"
    case short = "dd/MM/yyyy"
    
    /// "15 сентября 2021"
    case medium = "dd MMMM yyyy"
    
    /// "15.09.2021"
    case normal = "dd.MM.yyyy"
}

enum CustomFont: String {
    case coreSansC65Bold = "CoreSansC-65Bold"
    case coreSansC35Light = "CoreSansC-35Light"
    case coreSansC45Regular = "CoreSansC-45Regular"
    case coreSansC55Medium = "CoreSansC-55Medium"
}

enum ActivityStatus: String {
    case load = "lightPrimary"
    case error = "lightSecondaryB"
    case success = "lightSecondaryF"
}

enum UserState: String {
    /// User created account
    case registered = "0"
    
    /// User saved his phone in our database
    case phoneGiven = "1"
    
    /// User confirmed his phone number
    case phoneVerified = "2"
    
    /// User provided ID card
    case idProvided = "3"
    
    /// User accepted T&C
    case termsAccepted = "4"
}

struct ServerError: Error, Decodable {
    let statusCode: Int
    let message: String
}

extension ServerError {
    static let `default` = ServerError(statusCode: 400, message: "Unknown error")
}

enum ErrorAPI: Error {
    case unknownError
    case connectionError
    case invalidCredentials
    case invalidRequest
    case notFound
    case invalidResponse
    case serverError
    case serverUnavailable
    case timeOut
    case unsuppotedURL
    case noToken
    case routeError
    case transportError
    case neededSignUp
    case userNotAuthorized
}

func errorApiString(error: ErrorAPI) -> String {
  switch error {
    case .unknownError: return "Unknown error"
    case .connectionError: return "Connection error"
    case .invalidCredentials: return "Invalid credentials"
    case .invalidRequest: return "Invalid request"
    case .notFound: return "Not found"
    case .invalidResponse: return "Invalid response from server"
    case .serverError: return "Server error"
    case .serverUnavailable: return "Server is unavailable"
    case .timeOut: return "Tome out"
    case .unsuppotedURL: return "Unsupported url"
    case .noToken: return "No token"
    case .routeError: return "Route error"
    case .transportError: return "Transport error"
    case .neededSignUp: return "User needs to sign up"
    case .userNotAuthorized: return "User is not authorized"
  }
}


typealias RegistrationModeParameters = (width: CGFloat, title: String, note: String, error: String)

enum RegistrationMode {
    case providePhone
    case confirmPhone
    case verifyIdentity
    case deliveryDetails
    
    var parameters: RegistrationModeParameters {
        switch self {
        case .providePhone:
            return
                (width: 320 / 4,
                 title: "phonenumberview.phone_number_provide_phone_title",
                 note: "phonenumberview.phone_number_provide_phone_note",
                 error: "phonenumberview.phone_number_provide_phone_error")
            
        case .confirmPhone:
            return
                (width: 320 / 2,
                 title: "phonenumberview.phone_number_confirm_phone_title",
                 note: "phonenumberview.phone_number_confirm_phone_note",
                 error: "phonenumberview.phone_number_confirm_phone_error")

        case .verifyIdentity:
            return
                (width: 320 / 4 * 3,
                 title: "phonenumberview.phone_number_verify_identity_title",
                 note: "phonenumberview.phone_number_verify_identity_note",
                 error: "phonenumberview.phone_number_verify_identity_error")

        case .deliveryDetails:
            return
                (width: 320,
                 title: "phonenumberview.phone_number_delivery_details_title",
                 note: "phonenumberview.phone_number_delivery_details_note",
                 error: "phonenumberview.phone_number_delivery_details_error")
        }
    }
}

typealias URLsParameters = (url: URL?, title: String)

enum URLs {
    case privacyPolicy
    case termsConditions
    case customURL(urlString: String, title: String = "")

    var parameters: URLsParameters {
        switch self {
        case .privacyPolicy:
            return
                (url: URL(string: "\(BaseRepository().baseURL)/privacyPolicy"),
                 title: "phonenumberview.phone_number_verify_identity_description_privacy_policy")
            
        case .termsConditions:
            return
                (url: URL(string: "\(BaseRepository().baseURL)/termsAndConditions"),
                 title: "phonenumberview.phone_number_verify_identity_description_terms")
        
        case .customURL(let url, let title):
            return (url: URL(string: url), title: title)
        }
    }
}

enum SelectedTab: Hashable {
    case catalog
    case cart
    case profile
    case auth
    case userIdentification
}

enum MethodHTTP: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum PhoneMask: String {
    case american = "+X (XXX) XXX-XXXX"
    case ukrainian = "+XX (XXX) XXX-XX-XX"
}

enum DeliveryDetailsMode {
    case cart
    case order
    case registration
}
