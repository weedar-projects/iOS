//
//  PhoneVM.swift
//  Weedar
//
//  Created by Macdudls on 20.05.2022.
//

import SwiftUI
import Amplitude

class PhoneVM: ObservableObject {
    
    @Published var phoneEntered: String = "+1"
    @Published var phoneBorderColor: Color = Color.lightSecondaryE.opacity(0.1)
    @Published var myInfoItems:[ProfileMenuItemModel] = []
    @Published var phone = ""

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
                    Amplitude.instance().logEvent("number_changed")
                    //show button state
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        self.stepSuccess.toggle()
                    }
                    
                case let .failure(error):
                    
                    //log
                    Logger.log(message: error.localizedDescription, event: .error)
                    Amplitude.instance().logEvent("number_fail_change", withEventProperties: ["error_type": error.localizedDescription])
                    //error found
                    self.isErrorShow = true
                    self.errorMessage = error.localizedDescription
//                    self.errorMessage = "phonenumberview.phone_number_provide_phone_error".localized
                    self.buttonState = .def
                    break
                }
            }
    }
    init(){
        getUserData(userData: {data in
            self.phone = data.phone
        })
    }
    
    func getUserData(userData:@escaping(UserModel)-> Void){
            API.shared.request(rout: .getCurrentUserInfo) { result in
                switch result{
                case let .success(json):
                    let user = UserModel(json: json)
                    userData(user)
                case let .failure(error):
                    print("error to load user data: \(error)")
                }
            }
        }
}
