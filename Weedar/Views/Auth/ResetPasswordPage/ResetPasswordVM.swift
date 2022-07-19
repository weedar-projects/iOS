//
//  ResetPasswordVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI
 
import Alamofire

class ResetPasswordVM: ObservableObject {
    @Published var email: String = ""{
        didSet{
            if email.isEmailValid{
                emailTFState = .success
                buttonDisabled = false
            }else{
                emailTFState = .def
                buttonDisabled = true
            }
        }
    }
    @Published var emailTFState: TextFieldState = .def
    
    @Published var isAlertShow = false
    @Published var buttonState: ButtonState = .def
    @Published var buttonDisabled = true
    @Published var errorAPI: APIError?
    
    /// API `Reset Password`
    func resetPassword() {
        let params = [
            "email" : email
        ]
        API.shared.request(rout: Routs.resetPassword, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(_):
                self.isAlertShow = true
                self.buttonState = .success
                AnalyticsManager.instance.event(key: .reset_password_success)
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.buttonState = .def
                }
            case let .failure(error):
                self.errorAPI = error
                self.buttonState = .def
                AnalyticsManager.instance.event(key: .reset_password_fail, properties: [.error_type : error.message])
            }
        }
    }
}
