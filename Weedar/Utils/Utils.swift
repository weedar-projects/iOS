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
            UIApplication.shared.openURL(URL(string:"http://maps.apple.com/?q=\(formatedAddress)&sll=\(lat),\(lon)&z=10&t=s")!)
        } else {
          print("Can't use Apple Maps");
        }
    }
    
    func phoneFormat(phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in "+X (XXX) XXX-XXXXXX" where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
}
