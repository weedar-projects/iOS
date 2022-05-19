//
//  OrderDetailsReview.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct OrderDetailsReview {
    var orderId: Int
    var totalSum: Double
    var exciseTaxSum: Double
    var totalWeight: String?
    var salesTaxSum: Double
    var localTaxSum: Double
    var discount: Double
    var taxSum: Double
    var state: Int
}
