//
//  ARCarouselManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 19.04.2022.
//

import SwiftUI

class ARCarouselManager {
    
    var queue: [Int]
    var radius: Float
    
    
    init(products: [ARProductModel], radius: Float){
        
        var queueTemp: [Int] = []
        
        //Add Product to queue
        for product in products {
            queueTemp.append(product.id)
        }
        
        while queueTemp.count < 12 {
            queueTemp += queueTemp
        }
        
        self.queue = queueTemp
        
        self.radius = radius
    }
    
    
}

struct ARProductModel{
    var id: Int
    var modelFileName: String
    var productName: String
    var animationDuration: Double
    var modelScale: CGFloat
}
