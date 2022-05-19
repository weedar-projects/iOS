//
//  CartProduct.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct CartProduct: Identifiable, Hashable, Codable {
    var id: Int
    var item: Product
    var quantity: Int
    var imageLink: String
    
    var totalProductsGramWeight: Double {
        return Double(quantity) * item.grammWeightDouble()
    }
    
    var totalProductsPrice: Double {
        return Double(quantity) * item.price
    }
    
    var isConcentrated: Bool {
        return !(["flower", "seeds", "preroll", "plants"].contains(item.type.name.lowercased()))
    }
    
    mutating func changeQuantity(id: Int, _ num: Int) {
        if (self.id == id){
            self.quantity += num
        }
    }
}


let cartProductTest = [CartProduct(id: 0, item: Product(id: 0, name: "Product name", vendorCode: "123", thc: 12, labTestLink: "", imageLink: "", modelLowQualityLink: "", modelHighQualityLink: "", quantityInStock: 15, visible: true, price: 123, wholesalePrice: 12, cbd: 123, aspectRatio: 0, animationDuration: 0, gramWeight: 1.3, ounceWeight: 0, totalCannabinoids: 12, brand: Product.Brand(id: 0, name: "brand", description: "descriprion", imageLink: "link", productCount: 34), type: Product.Strain(id: 0, name: "strain"), strain: Product.Strain(id: 2, name: ""), effects: [Product.Effect(id: 1, name: "das")]), quantity: 3, imageLink: ""),
                       CartProduct(id: 0, item: Product(id: 0, name: "Product name", vendorCode: "123", thc: 12, labTestLink: "", imageLink: "", modelLowQualityLink: "", modelHighQualityLink: "", quantityInStock: 15, visible: true, price: 123, wholesalePrice: 12, cbd: 123, aspectRatio: 0, animationDuration: 0, gramWeight: 1.3, ounceWeight: 0, totalCannabinoids: 12, brand: Product.Brand(id: 0, name: "brand", description: "descriprion", imageLink: "link", productCount: 34), type: Product.Strain(id: 0, name: "strain"), strain: Product.Strain(id: 2, name: ""), effects: [Product.Effect(id: 1, name: "das")]), quantity: 3, imageLink: ""),
                       CartProduct(id: 0, item: Product(id: 0, name: "Product name", vendorCode: "123", thc: 12, labTestLink: "", imageLink: "", modelLowQualityLink: "", modelHighQualityLink: "", quantityInStock: 15, visible: true, price: 123, wholesalePrice: 12, cbd: 123, aspectRatio: 0, animationDuration: 0, gramWeight: 1.3, ounceWeight: 0, totalCannabinoids: 12, brand: Product.Brand(id: 0, name: "brand", description: "descriprion", imageLink: "link", productCount: 34), type: Product.Strain(id: 0, name: "strain"), strain: Product.Strain(id: 2, name: ""), effects: [Product.Effect(id: 1, name: "das")]), quantity: 3, imageLink: ""),
                       CartProduct(id: 0, item: Product(id: 0, name: "Product name", vendorCode: "123", thc: 12, labTestLink: "", imageLink: "", modelLowQualityLink: "", modelHighQualityLink: "", quantityInStock: 15, visible: true, price: 123, wholesalePrice: 12, cbd: 123, aspectRatio: 0, animationDuration: 0, gramWeight: 1.3, ounceWeight: 0, totalCannabinoids: 12, brand: Product.Brand(id: 0, name: "brand", description: "descriprion", imageLink: "link", productCount: 34), type: Product.Strain(id: 0, name: "strain"), strain: Product.Strain(id: 2, name: ""), effects: [Product.Effect(id: 1, name: "das")]), quantity: 3, imageLink: ""),
                       CartProduct(id: 0, item: Product(id: 0, name: "Product name", vendorCode: "123", thc: 12, labTestLink: "", imageLink: "", modelLowQualityLink: "", modelHighQualityLink: "", quantityInStock: 15, visible: true, price: 123, wholesalePrice: 12, cbd: 123, aspectRatio: 0, animationDuration: 0, gramWeight: 1.3, ounceWeight: 0, totalCannabinoids: 12, brand: Product.Brand(id: 0, name: "brand", description: "descriprion", imageLink: "link", productCount: 34), type: Product.Strain(id: 0, name: "strain"), strain: Product.Strain(id: 2, name: ""), effects: [Product.Effect(id: 1, name: "das")]), quantity: 3, imageLink: "")]
