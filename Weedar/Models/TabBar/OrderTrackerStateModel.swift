//
//  OrderTrackerStateModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI

struct OrderTrackerStateModel: Hashable {
    enum OrderTrackerDeliveryState: String {
        case submited = "Processing"
        case packing = "Packing"
        case inDelivery = "In delivery"
        case delivered = "Delivered"
    }
    
    enum OrderTrackerPickupState: String {
        case submited = "Processing"
        case packing = "Packing"
        case available = "Pick up available"
        case comlited = "Completed"
    }
    
    var id: Int
    var deliveryState: OrderTrackerDeliveryState
    var pickupState: OrderTrackerPickupState
    var colors: [Color]
    var deliveryText: String
    var pickupText: String
}

