//
//  OrderListModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.04.2022.
//

import SwiftUI
import SwiftyJSON


struct OrderModel: Identifiable{
    var id: Int
    var number, name, phone, city: String
    var addressLine1: String
    var addressLine2: String?
    var zipCode: String
    var sum: Double
    var deliverySum: Int
    var totalSum, exciseTaxSum, salesTaxSum, cityTaxSum: Double
    var taxSum, profitSum: Double
    var createdAt: String
    var state: Int
    var comment: String?
    var updatedAt: String
    var latitudeCoordinate, longitudeCoordinate: Double
    
    var area: AreaModel
    var detail: [ProductModel]?
    var userId, detailCount: Int?
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.number = json["number"].stringValue
        self.name = json["name"].stringValue
        self.phone = json["phone"].stringValue
        self.city = json["city"].stringValue
        self.addressLine1 = json["addressLine1"].stringValue
        self.addressLine2 = json["addressLine2"].stringValue
        self.zipCode = json["zipCode"].stringValue
        self.sum = json["sum"].doubleValue
        self.deliverySum = json["deliverySum"].intValue
        self.totalSum = json["totalSum"].doubleValue
        self.exciseTaxSum = json["exciseTaxSum"].doubleValue
        self.salesTaxSum = json["salesTaxSum"].doubleValue
        self.cityTaxSum = json["cityTaxSum"].doubleValue
        self.taxSum = json["taxSum"].doubleValue
        self.profitSum = json["profitSum"].doubleValue
        self.createdAt = json["createdAt"].stringValue
        self.state = json["state"].intValue
        self.comment = json["comment"].string
        self.updatedAt = json["updatedAt"].stringValue
        self.latitudeCoordinate = json["latitudeCoordinate"].doubleValue
        self.longitudeCoordinate = json["longitudeCoordinate"].doubleValue
        self.userId = json["userId"].intValue
        self.detailCount = json["detailCount"].intValue
        self.area = AreaModel(json: json["area"])
        self.detail = json["detail"].arrayValue.map({ProductModel(json: $0)})
    }
}
