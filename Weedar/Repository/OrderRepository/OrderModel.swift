//
//  OrderModel.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 13.08.2021.
//

import Foundation
import SwiftyJSON

struct OrderRequestError: Error {
    var message: String
    var data: Any?
}

struct OrderRequestModel: Codable {
    var name, phone, city, addressLine1: String
    var addressLine2, zipCode: String
    var user: Int
    var sum, deliverySum, totalSum: Double
    var latitudeCoordinate, longitudeCoordinate: Double
    var details: [Detail]

    struct Detail: Codable {
        var product, quantity: Int
    }

    init(userInfo: UserInfo, cartProducts: [CartDetails]) {
        self.name = userInfo.name! // use UserInfo.isCompleted to check values
        self.phone = userInfo.phone!
        self.user = userInfo.user!
        self.city = userInfo.city!
        self.zipCode = userInfo.zipCode!
        self.addressLine1 = userInfo.addressLine1!
        self.addressLine2 = userInfo.addressLine2
        self.sum = userInfo.sum!
        self.deliverySum = userInfo.deliverySum
        self.totalSum = userInfo.totalSum!
        self.latitudeCoordinate = userInfo.latitudeCoordinate
        self.longitudeCoordinate = userInfo.longitudeCoordinate

        self.details = []
        for product in cartProducts {
            self.details.append(Detail(product: product.product.id, quantity: product.quantity))
        }
    }
}

struct PartnerModel: Identifiable {
    var id: Int
    var name: String
    var address: String
    var weedMapsLink: String
    var contactEmail: String
    var deliveryEmail: String
    var isPickUp: Bool
    var phone: String
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    init(json:JSON){
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.address = json["address"].stringValue
        self.weedMapsLink = json["weedMapsLink"].stringValue
        self.contactEmail = json["contactEmail"].stringValue
        self.deliveryEmail = json["deliveryEmail"].stringValue
        self.isPickUp = json["isPickUp"].boolValue
        self.phone = json["phone"].stringValue
        self.latitudeCoordinate = json["latitudeCoordinate"].doubleValue
        self.longitudeCoordinate = json["longitudeCoordinate"].doubleValue
    }
}




struct OrderDetailOLD: Codable, Identifiable {
    var id, quantity: Int
    var createdAt: String
    var product: Product
    var productId, orderId: Int?
}

struct OrderResponseModelOLD: Codable, Identifiable, Hashable {
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
//    var partner: PartnerModel
    var area: Area
    var detail: [OrderDetailOLD]?
    var userId, detailCount: Int?

    struct Area: Codable, Identifiable {
        var id: Int
        var zipCode: String
        var partnerCount: Int
    }

    struct Product: Codable, Identifiable {
        var id: Int
        var name, vendorCode: String
        var thc: Double
        var labTestLink: String
        var imageLink, modelLowQualityLink, modelHighQualityLink: String
        var quantityInStock: Int
        var visible: Bool
        var price, wholesalePrice, cbd: Double
        var gramWeight, ounceWeight: Double
        var totalCannabinoids: Double
        var brand: Brand
        var type, strain: Strain
        var effects: [Strain]
    }

    struct Brand: Codable, Identifiable {
        var id: Int
        var name: String
        var brandDescription, imageLink: String?
        var productCount: Int
    }

    struct Strain: Codable, Identifiable {
        var id: Int
        var name: String
    }

  

    struct Settings: Codable, Hashable {
        var minSupplyQuantity, defaultSupplyQuantity: Int?
    }
    
    static func == (lhs: OrderResponseModelOLD, rhs: OrderResponseModelOLD) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        var hashValue: Int {
            var hasher = Hasher()
            self.hash(into: &hasher)
            return hasher.finalize()
        }
    }
}




struct OrderResponseModel: Identifiable {
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
    var gramWeight: Double
    var discount: DiscountModel?
    var updatedAt: String
    var latitudeCoordinate, longitudeCoordinate: Double
    var partner: PartnerModel
    var area: AreaModel
//    var detail: [OrderDetail]?
    var userId, detailCount: Int?
    var license: String
    var orderType: OrderType
    
    init(json: JSON) {
        self.license = json["license"].stringValue
        self.gramWeight = json["gramWeight"].doubleValue
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
        self.taxSum = json["cityTaxSum"].doubleValue
        self.profitSum = json["profitSum"].doubleValue
        self.createdAt = json["createdAt"].stringValue
        self.state = json["state"].intValue
        self.comment = json["comment"].string
        self.discount = DiscountModel(json: json["discount"]) 
        self.updatedAt = json["updatedAt"].stringValue
        self.latitudeCoordinate = json["latitudeCoordinate"].doubleValue
        self.longitudeCoordinate = json["longitudeCoordinate"].doubleValue
        self.userId = json["userId"].intValue
        self.detailCount = json["detailCount"].intValue
        self.area = AreaModel(json: json["area"])
        self.partner = PartnerModel(json: json["partner"])
        self.orderType = json["type"].intValue == 0 ? .delivery : .pickup
    }
}


struct AreaModel: Codable, Identifiable {
    var id: Int
    var zipCode: String
    var partnerCount: Int
    init(json: JSON) {
        self.id = json["partnerCount"].intValue
        self.zipCode = json["zipCode"].stringValue
        self.partnerCount = json["id"].intValue
    }
}

//struct OrderDetail: Codable, Identifiable {
//    var id: Int
//    var quantity: Int
//    var createdAt: String
//    var product: Product
//    var productId, orderId: Int?
//
//    init(json: JSON) {
//        self.id = json[""]
//        self.quantity = json[""]
//        self.createdAt = json[""]
//        self.product = json[""]
//        self.productId = json[""]
//        self.orderId = json[""]
//    }
//}


//extension OrderResponseModel {
//
//    static func mock(_ id: Int) -> OrderResponseModelOLD {
//        return OrderResponseModelOLD(
//            id: id,
//            number: "1234567",
//            name: "Some order",
//            phone: "11234567890",
//            city: "NY",
//            addressLine1: "Some avenue",
//            addressLine2: nil,
//            zipCode: "1234",
//            sum: 45,
//            deliverySum: 3,
//            totalSum: 48,
//            exciseTaxSum: 7,
//            salesTaxSum: 4,
//            cityTaxSum: 5,
//            taxSum: 4,
//            profitSum: 3,
//            createdAt: "",
//            state: 5,
//            comment: "",
//            updatedAt: "",
//            latitudeCoordinate: 45,
//            longitudeCoordinate: 34,
//            partner: nil,
//            area: Area.init(id: 2, zipCode: "1234", partnerCount: 4),
//            detail: nil,
//            userId: 34,
//            detailCount: 4
//        )
//    }
//
//}
