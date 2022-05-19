//
//  ResetPasswordVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI
import Amplitude

class ResetPasswordVM: ObservableObject {
    @Published var email: String = ""
    @Published var emailTFState: TextFieldState = .def
    
    @Published var showError = false
    @Published var isAlertShow = false
    @Published var buttonState: ButtonState = .def
    @Published var buttonDisabled = true
    @Published var errorAPI: ErrorAPI?
    
    /// API `Reset Password`
    func resetPassword() {
        
        if email.isEmailValid {
            DispatchQueue.main.async {
                self.buttonState = .loading
            }
            
            UserRepository
                .shared
                .resetPassword(byEmail: email) { result in
                    switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                                Amplitude.instance().logEvent("reset_password_success")
                                }
                                self.buttonState = .success
                                self.isAlertShow = true
                            }
                            
                        case .failure(let errorAPI):
                            Logger.log(message: errorAPI.localizedDescription, event: .error)
                        if UserDefaults.standard.bool(forKey: "EnableTracking"){
                            Amplitude.instance().logEvent("reset_password_fail")
                        }
                            self.hideActivityLoader(withErrorAPI: errorAPI)
                    }
                }
        } else {
            withAnimation {
                showError = true
            }
        }
    }
    
    private func hideActivityLoader(withErrorAPI errorAPI: ErrorAPI) {
        DispatchQueue.main.async {
            self.errorAPI = errorAPI
            self.buttonState = .def
            
            if errorAPI == .neededSignUp {
                self.showError = false
            } else {
                self.showError = true
            }
        }
    }
}
