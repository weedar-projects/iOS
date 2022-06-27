//
//  AddressModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI
import SwiftyJSON

struct AddressModel {
    var id: Int
    var city: String
    var addressLine1: String
    var addressLine2: String
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    var zipCode: String
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.city = json["city"].stringValue
        self.addressLine1 = json["addressLine1"].stringValue
        self.addressLine2 = json["addressLine2"].stringValue
        self.latitudeCoordinate = json["latitudeCoordinate"].doubleValue
        self.longitudeCoordinate = json["longitudeCoordinate"].doubleValue
        self.zipCode = json["zipCode"].stringValue
    }
    init(
        id: Int,
        city: String,
        addressLine1: String,
        addressLine2: String,
        latitudeCoordinate: Double,
        longitudeCoordinate: Double,
        zipCode: String){
            self.id = Int.random(in: 0...9999)
            self.city = city
            self.addressLine1 = addressLine1
            self.addressLine2 = addressLine2
            self.latitudeCoordinate = latitudeCoordinate
            self.longitudeCoordinate = longitudeCoordinate
            self.zipCode = zipCode
    }
}
