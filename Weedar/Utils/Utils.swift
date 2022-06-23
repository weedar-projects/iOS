//
//  Utils.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.06.2022.
//

import SwiftUI
import Foundation

class Utils {
    static let shared = Utils()
    
    func openGoogleMap(address: String,lat: Double, lon:Double) {
        let formatedAddress = address.replacingOccurrences(of: " ", with: "+")
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string: "comgooglemaps://?q=+\(formatedAddress)&center=\(lat),\(lon)&views=satellite,traffic&zoom=7")!)
        } else {
            UIApplication.shared.open(URL(string: "http://maps.google.com/maps?q=loc:\(lat),\(lon)&zoom=14&views=traffic&q=\(lat),\(lon)")!, options: [:], completionHandler: nil)

        }
    }
    
    func openAppleMap(address: String,lat: Double, lon: Double){
        let formatedAddress = address.replacingOccurrences(of: " ", with: "+")
        if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com")!)) {
            UIApplication.shared.openURL(URL(string:"http://maps.apple.com/?daddr=\(formatedAddress)")!)
        } else {
          print("Can't use Apple Maps");
        }
    }
}
