//
//  SwiftUIView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 26.04.2022.
//

import SwiftUI

enum EnvironmentAPI: String {
    case production
    case dev
    case stage
    
    var baseUrl: String {
        switch self {
        case .dev:
            return "http://api-dev.weedar.tech"
        case .stage:
            return "http://api-stage.weedar.tech"
        default:
            return "https://api.weedar.tech"
        }
    }
}

class PKSettingsBundleHelper {
    static let shared = PKSettingsBundleHelper()
    
    private init() {}
    
    var currentEnvironment: EnvironmentAPI {
        var env: EnvironmentAPI = .production
    #if DEBUG
        if let env = UserDefaults.standard.string(forKey: "currentEnvironment") {
            return EnvironmentAPI(rawValue: env.lowercased()) ?? EnvironmentAPI.production
        }
        env = EnvironmentAPI.production
    #endif
        return env
    }
}
