//
//  ContactUsVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 12.04.2022.
//

import SwiftUI
import Alamofire

class ContactUsVM: ObservableObject {
    @Published var messageTitle = ""
    @Published var messageTitleState: TextFieldState = .def
    
    @Published var messageText = ""
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = true

    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var alertTitle = ""
    
    
    func validateButton(){
        if messageText.isEmptyOrWhitespace(){
            buttonIsDisabled = true
        }else{
            if !messageTitle.isEmptyOrWhitespace(){
                buttonIsDisabled = false
            }
        }
    }
    
    func sendMessage() {
        let params = [
            "title" : messageTitle,
            "message" : messageText
        ]
        
        API.shared.request(rout: .sendSupportMessage, method: .post, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(_):
                self.updateView()
                self.alertMessage = "Your message has been successfully sent."
                self.alertTitle = "Thank you!"
                self.showAlert = true
            case let .failure(error):
                print("ERROR: \(error)")
                self.alertMessage = error.message
                self.alertTitle = "Ooops"
                self.showAlert = true
            }
        }
    }
    
    func updateView(){
        buttonIsDisabled = true
        buttonState = .def
        messageText = ""
        messageTitle = ""
    }
}

