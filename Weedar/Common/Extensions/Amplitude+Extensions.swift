//
//  Amplitude+Extensions.swift
//  Weelar
//
//  Created by Hayk Aghavelyan on 24.01.22.
//

import Foundation
import Amplitude

extension Amplitude {

    // User's properties are set in Amplitude Analytics
    static func setAmpUserProperty(key: String, value: NSObject) {
        let identify = AMPIdentify()
            .set(key, value: value)
        if let identify = identify  {
            Amplitude.instance().identify(identify)
        }
    }

   // User's properties value is increased in Amplitude Analytics
    static func addAmpUserProperty(key: String, value: NSObject) {
        let identify = AMPIdentify()
            .add(key, value: value)
        if let identify = identify  {
            Amplitude.instance().identify(identify)
        }
    }
}
