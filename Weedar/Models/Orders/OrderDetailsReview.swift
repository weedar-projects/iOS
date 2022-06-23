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
    var discount: DiscountModel?
    var taxSum: Double
    var sum: Double
    var state: Int
    var fullAdress: String
    var username: String
    var phone: String
    
    var partnerPhone: String
    var partnerName: String
    var partnerAdress: String
    
    var licence: String = ""
}
