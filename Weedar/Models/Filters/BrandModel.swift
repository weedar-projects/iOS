//
//  BrandModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 04.04.2022.
//

import SwiftUI
import SwiftyJSON

struct BrandModel: Identifiable, Hashable {
    var id: Int
    var name: String
    var imageLink: String
    var productCount: String
    var description: String
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.imageLink = json["imageLink"].stringValue
        self.productCount = json["productCount"].stringValue
        self.description = json["description"].stringValue
    }
}
