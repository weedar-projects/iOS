//
//  OrderReviewVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 13.03.2022.
//

import SwiftUI

class OrderReviewVM: ObservableObject {
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = false
    @Published var disableNavButton = false
    @Published var showAlert = false
    @Published var showSuccessView = false
    @Published var showLoading = false
    
    func confirmOrder(orderDetailsReview : OrderDetailsReview, finished: @escaping(Bool) -> Void) {
        
        let url = "/order/\(orderDetailsReview.orderId)/confirm"
        
        API.shared.request(endPoint: url, method: .put, completion:  { result in
            switch result {
            case .success(_):
                finished(true)
            case .failure(let error):
                print(error.localizedDescription)
                finished(false)
            }
        })
    }
}
