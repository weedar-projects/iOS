//
//  ProductModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 30.03.2022.
//

import SwiftUI
import SwiftyJSON

struct ProductModel: Identifiable, Hashable {
    
    struct Brand: Identifiable, Hashable {
        var id: Int
        var name, description, imageLink: String?
        var productCount: Int
        
        init(json: JSON) {
            self.id = json["id"].intValue
            self.name = json["name"].stringValue
            self.description = json["description"].stringValue
            self.imageLink = json["imageLink"].stringValue
            self.productCount = json["productCount"].intValue
        }
    }

    struct Strain: Identifiable, Hashable {
        var id: Int
        var name: String
        
        init(json: JSON) {
            self.id = json["id"].intValue
            self.name = json["name"].stringValue
        }
        
    }

    struct Effect: Identifiable, Hashable {
        var id: Int
        var name: String
        var emoji: String
        
        init(json: JSON) {
            self.id = json["id"].intValue
            self.name = json["name"].stringValue
            self.emoji = json["emoji"].stringValue
        }
    }
    
    var id: Int
    var name, vendorCode: String
    var thc: Double
    var labTestLink: String?
    var imageLink, modelLowQualityLink, modelHighQualityLink: String
    var quantityInStock: Int
    var visible: Bool
    var price, wholesalePrice: Double
    var cbd: Double
    var aspectRatio: Double?
    var animationDuration: Double
    var gramWeight, ounceWeight: Double
    var totalCannabinoids: Double
    var brand: Brand
    var type: CatalogCategoryModel
    var strain: Strain
    var effects: [Effect]
    var quantity: Int = 0
    var isNft: Bool
    
    // temp, backend
    func grammWeightDouble() -> Double {
        return gramWeight
    }

    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.vendorCode = json["vendorCode"].stringValue
        self.thc = json["thc"].doubleValue
        self.labTestLink = json["labTestLink"].stringValue
        self.imageLink = json["imageLink"].stringValue
        self.modelLowQualityLink = json["modelLowQualityLink"].stringValue
        self.modelHighQualityLink = json["modelHighQualityLink"].stringValue
        self.quantityInStock = json["weight"].intValue
        self.visible = json["visible"].boolValue
        self.price = json["price"].doubleValue
        self.wholesalePrice = json["wholesalePrice"].doubleValue
        self.cbd = json["cbd"].doubleValue
        self.aspectRatio = json["aspectRatio"].doubleValue
        self.animationDuration = json["animationDuration"].doubleValue
        self.gramWeight = json["gramWeight"].doubleValue
        self.ounceWeight = json["ounceWeight"].doubleValue
        self.totalCannabinoids = json["totalCannabinoids"].doubleValue
        self.brand = Brand(json: json["brand"])
        self.type = CatalogCategoryModel(json: json["type"])
        self.strain = Strain(json: json["strain"])
        self.effects = json["effects"].arrayValue.map({ Effect(json: $0) })
        self.quantity = json["quantity"].intValue
        self.isNft = json["isNft"].boolValue
    }
}
