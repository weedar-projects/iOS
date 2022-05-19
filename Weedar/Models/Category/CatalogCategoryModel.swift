//
//  CategoryModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 30.03.2022.
//

import SwiftUI
import SwiftyJSON


struct CatalogCategoryModel: Hashable {
    var id: Int
    var name: String
    var itemsCount: Int = 0

    var emoji: String {
        if emojies.indices.contains(id - 1) {
            return emojies[id - 1]
        }
        return "🍾"
    }
    
    var imagePreview: String {
        if images.indices.contains(id - 1) {
            return images[id - 1]
        }
        return "CatalogVapePreview"
    }
    
    var color: Color {
        if colors.indices.contains(id - 1) {
            return colors[id - 1]
        }
        return ColorManager.Catalog.Category.vapeColor
    }
    
    private let colors = [ColorManager.Catalog.Category.vapeColor,
                          ColorManager.Catalog.Category.flowerColor,
                          ColorManager.Catalog.Category.concentrateColor,
                          ColorManager.Catalog.Category.edibleColor,
                          ColorManager.Catalog.Category.tinctureColor,
                          ColorManager.Catalog.Category.plantsColor,
                          ColorManager.Catalog.Category.seedsColor,
                          ColorManager.Catalog.Category.prerollColor]
    
    private let emojies = ["😤", "🥀", "🍯", "🍭", "🥃", "🌴", "🌱", "🚬"]
    
    private let images = ["CatalogVapePreview",
                          "CatalogFlowerPreview",
                          "CatalogConcentratePreview",
                          "CatalogEdiablePreview",
                          "CatalogTincturePreview",
                          "CatalogPlantsPreview",
                          "CatalogSeedsPreview",
                          "CatalogPrerollPreview",
                          "CatalogGummiePreview"]
    
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.itemsCount  = json["productCount"].intValue
    }
}
