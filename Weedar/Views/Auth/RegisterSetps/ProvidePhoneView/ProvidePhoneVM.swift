//
//  ProvidePhoneVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.03.2022.
//

import SwiftUI
import Amplitude

class ProvidePhoneVM: ObservableObject {
    
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
                   
                    //set button state
                    self.buttonState = .success
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){
                    Amplitude.instance().logEvent("number_success")
                    }
                    //show button state
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        self.stepSuccess.toggle()
                    }
                    
                case let .failure(error):
                    
                    //log
                    Logger.log(message: error.localizedDescription, event: .error)
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){
                    Amplitude.instance().logEvent("number_fail", withEventProperties: ["error_type": error.localizedDescription])
                    }
                    //error found
                    self.isErrorShow = true
                    self.errorMessage = error.localizedDescription
//                    self.errorMessage = "phonenumberview.phone_number_provide_phone_error".localized
                    self.buttonState = .def
                    break
                }
            }
    }
}
 
