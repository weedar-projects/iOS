//
//  UserInfoModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI
import SwiftyJSON

struct UserInfoModel {
    var id: Int
    var email: String
    var name: String
    var state: String
    var phone: String
    var passportPhotoLink: String
    var physicianRecPhotoLink: String
    var addresses: [AddressModel]
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.email = json["email"].stringValue
        self.name = json["name"].stringValue
        self.state = json["state"].stringValue
        self.phone = json["phone"].stringValue
        self.passportPhotoLink = json["passportPhotoLink"].stringValue
        self.physicianRecPhotoLink = json["physicianRecPhotoLink"].stringValue
        self.addresses = json["addresses"].arrayValue.map({AddressModel(json: $0)})
    }
}


struct UserInfo {
    var name: String?
    var phone: String?
    var city: String?
    var addressLine1: String?
    var addressLine2: String = "none"
    var zipCode: String?
    var user: Int?
    var sum: Double?
    var deliverySum: Double = 10.0 // default
    var totalSum: Double?
    var latitudeCoordinate: Double = 1.0
    var longitudeCoordinate: Double = 1.0
    var wholesalePrice: Double = 1.0
    
    //TODO: Improve
    func isCompleted() -> Bool {
        guard let name = self.name else {
            print("Name field is not set!")
            return false
        }
        
        guard let phone = self.phone else {
            print("Phone field is not set!")
            return false
        }
        
        guard let city = self.city else {
            print("City field is not set!")
            return false
        }
        
        guard let addressLine1 = self.addressLine1 else {
            print("City field is not set!")
            return false
        }
        
        guard let zipCode = self.zipCode else {
            print("ZipCode field is not set!")
            return false
        }
        
        guard user != nil else {
            print("UserID field is not set!")
            return false
        }
        
        guard sum != nil else {
            print("Sum field is not set!")
            return false
        }
        
        guard totalSum != nil else {
            print("TotalSum field is not set!")
            return false
        }
        
        for data in [name, phone, city, addressLine1, zipCode] {
            if data.isEmpty {
                return false
            }
        }
        
        return true
    }
}
