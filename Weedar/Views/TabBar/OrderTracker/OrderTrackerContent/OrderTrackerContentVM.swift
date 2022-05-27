//
//  OrderTrackerContentVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI

class OrderTrackerContentVM: ObservableObject {
    let allState: [OrderTrackerStateModel] = [
        OrderTrackerStateModel(id: 0, state: .submited,
                               color: Color.col_yellow_orderTracker,
                               deliveryText: "Delivery partner is reviewing your order."),
        OrderTrackerStateModel(id: 1, state: .packing,
                               color: Color.col_blue_orderTracker,
                               deliveryText: "Delivery partner is preparing your order."),
        OrderTrackerStateModel(id: 2,
                               state: .inDelivery,
                               color: Color.col_orange_orderTracker,
                               deliveryText: "The driver is on the way."),
        OrderTrackerStateModel(id: 3,
                               state: .delivered,
                               color: Color.col_green_orderTracker,
                               deliveryText: "The order is delivered.Thank you for choosing WEEDAR.")
    ]
    
        
    
    @Published var showCancelAlert = false
    
    @Published var loading = false
    
    let orderReview = OrderDetailsReview(orderId: 0, totalSum: 0, exciseTaxSum: 0, totalWeight: "", salesTaxSum: 0, localTaxSum: 0, discount: nil, taxSum: 0, state: 0)
    
    func cancelOrder(orderID: Int,completion: @escaping () -> Void){
        let endPoint = "/order/\(orderID)/cancel"
        
        API.shared.request(endPoint: endPoint, method: .put) { result in
            switch result {
            case .success(_):
                completion()
            case .failure(_):
                completion()
            }
        }
    }
    
    
}
