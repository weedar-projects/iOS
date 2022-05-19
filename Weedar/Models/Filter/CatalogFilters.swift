//
//  CatalogFilters.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct CatalogFilters {
    var search: String?
    var effects: Set<Int>?
    var brands: Set<Int>?
    var priceFrom: Double? = 0
    var priceTo: Double? = 199
}

enum CatalogFilterKey: String {
    case search = "search"
    case type = "type"
    case brand = "brand"
    case strain = "strain"
    case effect = "effect"
    case priceFrom = "priceFrom"
    case priceTo = "priceTo"
}
