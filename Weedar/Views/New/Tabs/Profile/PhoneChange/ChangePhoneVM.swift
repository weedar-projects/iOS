//
//  ChangePhoneVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 03.06.2022.
//

import SwiftUI

class ChangePhoneVM: ObservableObject {
    
    @Published var phoneEntered: String = "+1"
    
    @Published var phoneBorderColor: Color = Color.lightSecondaryE.opacity(0.1)
    
    @Published var isErrorShow: Bool = false {
        didSet {
            if isErrorShow {
                phoneBorderColor = Color.lightSecondaryE.opacity(0.1)
            } else {
                phoneBorderColor = Color.lightSecondaryB.opacity(0.4)
            }
        }
    }
    
    @Published var errorMessage: String = ""
    
    @Published var showOTPView = false
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = true
    
    @Published var stepSuccess = false
    
    let ud = UserDefaultsService()
    
    var verificationID: String = ""
    
    //send code
    func sendPhoneAuthentication() {
        self.buttonState = .loading
        
        FirebaseAuthManager
            .shared
            .getConfirmationCode(phoneEntered) { result in
                switch result {
                case let .success(verificationID):
                    //verificationID - code for activate number
                    self.verificationID = verificationID
                    self.showOTPView = true
                    //set button state
                    self.buttonState = .success
                    
                case let .failure(error):
                    
                    //log
                    Logger.log(message: error.localizedDescription, event: .error)
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){
                        
                        //error found
                        self.isErrorShow = true
                        self.errorMessage = error.localizedDescription
                        self.buttonState = .def
                        break
                    }
                }
            }
    }
}
