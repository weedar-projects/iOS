
//
//  ProductModel.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 10.08.2021.
//

import Foundation

enum ProductRequestError: Error {
    case invalidRequest
    case custom(errorMessage: String)
}

struct Product: Codable, Identifiable, Hashable {
    var id: Int
    var name, vendorCode: String
    var thc: Double
    var labTestLink: String?
    var imageLink, modelLowQualityLink, modelHighQualityLink: String
    var quantityInStock: Int
    var visible: Bool
    var price, wholesalePrice: Double
    var cbd: Double
    var aspectRatio: Float?
    var animationDuration: Double
    var gramWeight, ounceWeight: Double
    var totalCannabinoids: Double
    var brand: Brand
    var type, strain: Strain
    var effects: [Effect]
    
    // temp, backend
    func grammWeightDouble() -> Double {
        return gramWeight
    }

    struct Brand: Codable, Identifiable, Hashable {
        var id: Int
        var name, description, imageLink: String?
        var productCount: Int
        
        static func == (lhs: Brand, rhs: Brand) -> Bool {
            return lhs.id == rhs.id
        }
    }

    struct Strain: Codable, Identifiable, Hashable {
        var id: Int
        var name: String
        
        static func == (lhs: Strain, rhs: Strain) -> Bool {
            return lhs.id == rhs.id
        }
        
    }

    struct Effect: Codable, Identifiable, Hashable {
        var id: Int
        var name: String
        
        func emoji() -> String {
            let emojies = ["😴", "☺️", "😌", "😛", "🎨", "😎", "😂", "💬", "🍑", "😀", "😬", "🤔"]

            if emojies.indices.contains(id - 1) {
                return emojies[id - 1]
            }
            return "🍾"
        }

        static func == (lhs: Effect, rhs: Effect) -> Bool {
            return lhs.id == rhs.id
        }
        
    }

    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}
