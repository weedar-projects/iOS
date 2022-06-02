//
//  ChangeEmailVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 02.06.2022.
//

import SwiftUI
import Alamofire

class ChangeEmailVM: ObservableObject {
    @Published var email = ""{
        didSet{
            validateFields()
        }
    }
    @Published var emailTFState: TextFieldState = .def
    
    @Published var password = ""{
        didSet{
            validateFields()
        }
    }
    @Published var passwordTFState: TextFieldState = .def
    
    @Published var buttonState: ButtonState = .def
    
    @Published var buttonIsDisable = true
    
    @Published var user: UserModel?
    
    @Published var errorMessage = ""
    
    @Published var showSuccessAlert = false
    
    func changeEmail(userID: Int, finish: @escaping () -> Void){
        let endPoint = Routs.user.rawValue + "/\(userID)/updateEmail"
        
        let params = [
            "email": email,
            "password": password
        ]
    
        API.shared.request(endPoint: endPoint, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(_):
                self.email = ""
                self.password = ""
                self.buttonState = .def
                finish()
            case let .failure(error):
                self.passwordTFState = .error
                self.emailTFState = .error
                self.errorMessage = error.message
                self.buttonState = .def
            }
        }
    }
    
    func validateFields(){
        errorMessage = ""
        passwordTFState = .def
        emailTFState = .def
        if email == ""{
            buttonIsDisable = true
        }else if password == ""{
            buttonIsDisable = true
        }else{
            buttonIsDisable = false
        }
    }
}
