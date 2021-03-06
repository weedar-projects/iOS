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
    @Published var alerMessage = ""
    @Published var showSuccessView = false
    @Published var showLoading = false
    
    
    func confirmOrder(orderDetailsReview : OrderDetailsReview, finished: @escaping(Bool) -> Void) {
        
        let url = "/order/\(orderDetailsReview.orderId)/confirm"

        API.shared.request(endPoint: url, method: .put, completion:  { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    finished(true)
                }
            case .failure(let error):
                self.alerMessage = error.message
                finished(false)
            }
        })
    }
}
