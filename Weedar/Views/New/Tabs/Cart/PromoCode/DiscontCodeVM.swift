//
//  DiscontCodeVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 27.05.2022.
//

import SwiftUI
import Alamofire

class DiscontCodeVM: ObservableObject {
    @Published var code = ""{
        didSet{
            btnDisabled = code.isEmpty
            errorMessage = ""
        }
    }
    @Published var codeTFState: TextFieldState = .def
    
    @Published var buttonState: ButtonState = .def
    @Published var btnDisabled = true
    
    @Published var errorMessage = ""
    
    func applyDiscount(success: @escaping (CartModel) -> Void) {
        let params = [
            "promoCode" : code
        ]
        API.shared.request(rout: .cart, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(let json):
                let data = CartModel(json: json)
                self.buttonState = .success
                self.codeTFState = .success
                success(data)
                
            case .failure(let error):
                self.errorMessage = error.message
                self.codeTFState = .error
                self.buttonState = .def
            }
        }
    }
}
