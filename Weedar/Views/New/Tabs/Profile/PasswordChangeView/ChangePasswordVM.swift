//
//  ChangePasswordVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 02.06.2022.
//

import SwiftUI
import Alamofire

class ChangePasswordVM: ObservableObject {
    @Published var oldPassword = ""{
        didSet{
            validateFields()
        }
    }
    @Published var newPassword = ""{
        didSet{
            validateRepeatPassword()
            validateFields()
        }
    }
    @Published var newPasswordRepeat = ""{
        didSet{
            validateRepeatPassword()
            validateFields()
        }
    }
    
    @Published var oldPasswordTFState: TextFieldState = .def
    @Published var newPasswordTFState: TextFieldState = .def
    @Published var newPasswordRepeatTFState: TextFieldState = .def
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisable = true
    
    @Published var showSuccessAlert = false
    
    @Published var errors: [PasswordError] = [.charactersCount, .oneUppercaseLetter, .oneDigit, .oneLowercaseLetter]
    
    @Published var serverError = ""
    @Published var showRepeatPasswordError = false
    
    func validatePassword(_ password: String) {
        var errors = [PasswordError]()
        
        switch password {
            case "": errors = [.charactersCount, .oneUppercaseLetter, .oneDigit, .oneLowercaseLetter]
            case let password where password.range(of: PasswordError.oneLowercaseLetter.pattern, options: .regularExpression) == nil:
                errors.append(.oneLowercaseLetter)
                fallthrough
            case let password where password.range(of: PasswordError.oneDigit.pattern, options: .regularExpression) == nil:
                errors.append(.oneDigit)
                fallthrough
            case let password where password.range(of: PasswordError.oneUppercaseLetter.pattern, options: .regularExpression) == nil:
                errors.append(.oneUppercaseLetter)
                fallthrough
                
            default:
                if password.trimmingCharacters(in: .whitespaces
                ).count < 8 {
                    errors.append(.charactersCount)
                }
        }
        self.errors = errors
        
    }
    
    
    func validateFields() {
        validatePassword(newPassword)
        if oldPassword == "" {
            buttonIsDisable = true
        }else if newPassword == "" {
            buttonIsDisable = true
        }else if newPasswordRepeat == ""{
            buttonIsDisable = true
        }else if errors.isEmpty{
            buttonIsDisable = false
        }else{
            buttonIsDisable = true
        }
    }
    
    func validateRepeatPassword(tapButton: Bool = false) -> Bool{
        if newPassword == newPasswordRepeat{
            if errors.isEmpty{
                newPasswordTFState = .success
                newPasswordRepeatTFState = .success
                return true
            }
        }else {
            if tapButton{
                newPasswordTFState = .error
                newPasswordRepeatTFState = .error
                buttonState = .def
                showRepeatPasswordError = true
            }else{
                newPasswordTFState = .def
                newPasswordRepeatTFState = .def
            }
            
        }
        return false
    }
    
    
    func updatePassword(userID: Int,finish: @escaping () -> Void) {
        let endPoint = Routs.user.rawValue + "/\(userID)/updatePassword"
        
        let params = [
            "oldPassword": oldPassword,
            "password": newPassword
        ]
        
        API.shared.request(endPoint: endPoint, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(_):
                finish()
                self.buttonState = .success
                AnalyticsManager.instance.event(key: .change_pass_success)
            case .failure(let error):
                self.serverError = error.message
                self.buttonState = .def
                AnalyticsManager.instance.event(key: .change_pass_fail, properties: [.error_type : error.message])
            }
        }
    }
}

