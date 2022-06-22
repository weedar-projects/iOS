//
//  StoreModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI
import MapKit
import SwiftyJSON

struct StoreModel: Identifiable {
    let id: Int
    let name: String
    let address: String
    var weedMapsLink: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)
    var contactEmail: String
    var deliveryEmail: String
    var license: String
    var phone: String
    var close: Bool
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.address = json["address"].stringValue
//        self.weedMapsLink = json["weedMapsLink"].stringValue
        self.contactEmail = json["contactEmail"].stringValue
        self.deliveryEmail = json["deliveryEmail"].stringValue
        self.license = json["license"].stringValue
        self.phone = json["phone"].stringValue
        self.close = json["close"].boolValue
    }
    
    init( id: Int,
          name: String,
          address: String,
//          weedMapsLink: String,
          contactEmail: String,
          deliveryEmail: String,
          license: String,
          phone: String,
          close: Bool){
        self.id = id
        self.name = name
        self.address = address
//        self.weedMapsLink = weedMapsLink
        self.contactEmail = contactEmail
        self.deliveryEmail = deliveryEmail
        self.license = license
        self.phone = phone
        self.close = close
    }
}
