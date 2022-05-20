//
//  EmailVM.swift
//  Weedar
//
//  Created by Macdudls on 20.05.2022.
//

import SwiftUI

class EmailVM: ObservableObject {
    @Published var myInfoItems:[ProfileMenuItemModel] = []

    @Published var emailTitle = ""
    @Published var emailTitleState: TextFieldState = .def
    
    @Published var passwordTitle = ""
    @Published var passwordTitleState: TextFieldState = .def

    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = true

    @Published var showAlert = false
    @Published var errorMessage = ""
    @Published var email = ""
    @Published var user: UserModel?

    init(){
        getUserData(userData: {data in
            self.email = data.email
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
    
    func ChangeEmail() {
        let params = [
            "email" : emailTitle,
            "password" : passwordTitle
        ]
        
    }
    
    func updateView(){
        buttonIsDisabled = true
        buttonState = .def
        emailTitle = ""
        passwordTitle = ""
    }
}
