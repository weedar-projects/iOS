//
//  DeliveryZipCodesModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 10.03.2022.
//

import Foundation
import SwiftyJSON


struct DeliveryZipCodesModel: Codable, Identifiable {
    var id: Int
    var zipCode: String
    var partnerCount: Int
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.zipCode = json["zipCode"].stringValue
        self.partnerCount = json["partnerCount"].intValue
    }
}

struct DeliveryZipCodesError: Error {
    var message: String
}
