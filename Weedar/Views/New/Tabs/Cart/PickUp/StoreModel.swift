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
    var id: Int
    var address: String
    var phone: String
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    var timeWork: String
    var daysWork: String
    var close: Bool
    var distance: Double
    init(json: JSON, distance: Double = -1){
        self.distance = distance
        self.id = json["id"].intValue
        self.address = json["addressLine1"].stringValue
        self.phone = json["phone"].stringValue
        self.latitudeCoordinate = json["latitudeCoordinate"].doubleValue
        self.longitudeCoordinate = json["longitudeCoordinate"].doubleValue
        self.timeWork = json["timeWork"].stringValue
        self.daysWork = json["daysWork"].stringValue
        self.close = json["close"].boolValue
    }
    
    init(
    id: Int,
    address: String,
    phone: String,
    latitudeCoordinate: Double,
    longitudeCoordinate: Double,
    timeWork: String,
    daysWork: String,
    close: Bool,
    distance: Double = -1){
        self.id = id
        self.address = address
        self.phone = phone
        self.latitudeCoordinate = latitudeCoordinate
        self.longitudeCoordinate = longitudeCoordinate
        self.timeWork = timeWork
        self.daysWork = daysWork
        self.close = close
        self.distance = distance
    }
}
