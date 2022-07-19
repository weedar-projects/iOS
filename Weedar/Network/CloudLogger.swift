//
//  CloudLogger.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 04.07.2022.
//

import SwiftUI
import SwiftyBeaver

class CloudLogger {
    
    static let shared = CloudLogger()
    
    enum LogState {
        case error
        case info
        case debug
    }
    
    
    func cloudLog(logData: Any, logState: LogState){
        let log = SwiftyBeaver.self
        
        guard let user = UserDefaultsService().get(fromKey: .user) else {
            log.info("USER: <NOT LOGIN> \(logData)")
            return
        }
        
        switch logState {
        case .error:
            log.error("USER: \(user) \(logData)")
        case .info:
            log.info("USER: \(user)  \(logData)")
        case .debug:
            log.debug("USER: \(user) \(logData)")
        }
        
    }
}

