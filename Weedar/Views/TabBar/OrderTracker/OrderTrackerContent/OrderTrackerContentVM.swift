//
//  OrderTrackerContentVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI

class OrderTrackerContentVM: ObservableObject {
    let allState: [OrderTrackerStateModel] = [
        OrderTrackerStateModel(id: 0,
                               deliveryState: .submited,
                               pickupState: .submited,
                               colors: [Color.col_gradient_orange_first, Color.col_gradient_orange_second],
                               deliveryText: "Delivery partner is reviewing your order.",
                               pickupText: "Delivery partner is reviewing your order."),
        OrderTrackerStateModel(id: 1,
                               deliveryState: .packing,
                               pickupState: .packing,
                               colors: [Color.col_violet_status_bg, Color.col_white],
                               deliveryText: "Delivery partner is preparing your order.",
                               pickupText: "Delivery partner is preparing your pick up."),
        OrderTrackerStateModel(id: 2,
                               deliveryState: .inDelivery,
                               pickupState: .available,
                               colors: [Color.col_gradient_blue_first, Color.col_gradient_blue_second],
                               deliveryText: "The driver is on the way.",
                               pickupText: "Your order is available for pick up now."),
        OrderTrackerStateModel(id: 3,
                               deliveryState: .delivered,
                               pickupState: .comlited,
                               colors: [Color.col_gradient_green_first, Color.col_gradient_green_second],
                               deliveryText: "The order is delivered.Thank you for choosing WEEDAR.",
                               pickupText: "The order is successfully completed. Enjoy!")
    ]
    
        
    
    @Published var showCancelAlert = false
    
    @Published var loading = false
    
    @Published var showDirectionsView = false
    
    let orderReview = OrderDetailsReview(orderId: 0, totalSum: 0, exciseTaxSum: 0, totalWeight: "", salesTaxSum: 0, localTaxSum: 0, discount: nil, taxSum: 0, sum: 0, state: 0, fullAdress: "",username: "",phone: "",partnerPhone: "", partnerName: "", partnerAdress: "", orderNumber: "")
    
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
