//
//  OrderTrackerStateModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI

struct OrderTrackerStateModel: Hashable {
    enum OrderTrackerState: String {
        case submited = "Processing"
        case packing = "Packing"
        case inDelivery = "In delivery"
        case delivered = "Delivered"
    }
    var id: Int
    var state: OrderTrackerState
    var colors: [Color]
    var deliveryText: String
}
