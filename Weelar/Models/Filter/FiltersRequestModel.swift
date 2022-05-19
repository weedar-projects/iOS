//
//  FiltersRequestModel.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 07.10.2021.
//

import Foundation

struct FiltersRequestModel: Codable, Equatable {    
    var priceTo: Int?
    var priceFrom: Int?
    var brands: Set<Int>?
    var effects: Set<Int>?
}
