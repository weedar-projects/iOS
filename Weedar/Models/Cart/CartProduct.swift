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
