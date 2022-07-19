//
//  ChangeEmailView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 02.06.2022.
//

import SwiftUI

struct ChangeEmailView: View {
    
    var needToUpdateEmail: ()-> Void
    
    @StateObject var vm = ChangeEmailVM()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack{
            VStack{
                if let userEmail = vm.user?.email{
                    Text("Current email – \(userEmail)")
                        .textSecond()
                        .hLeading()
                        .padding(.horizontal, 24)
                        .padding(.top)
                }
                
                CustomTextField(text: $vm.email, state: $vm.emailTFState, title: "New email", placeholder: "Enter your new email", keyboardType: .emailAddress)
                    .padding(.top, 24)
                
                CustomSecureTextField(text: $vm.password, state: $vm.passwordTFState, title: "Password", placeholder: "Enter your password")
                    .padding(.top, 24)
                    
                Text(vm.errorMessage)
                    .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
                    .padding(.horizontal, 24)
                    .hLeading()
                
                Spacer()
            }
            
            VStack{
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisable,showIcon: false ,title: "Change email") {
                    sessionManager.userData { user in
                        vm.changeEmail(userID: user.id) {
                            sessionManager.userData(withUpdate: true) { user in
                                self.vm.user = user
                                self.vm.showSuccessAlert = true
                                needToUpdateEmail()
                            }
                        }
                    }
                    
                }
                .padding(.horizontal, 24)
                .padding(.bottom, isSmallIPhone() ? 16 : 0)
                .vBottom()
            }.ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navBarSettings("Change email")
        .customAlertOneBtn(title: "Congratulations!", message: "Your email is successfully changed.", isPresented: $vm.showSuccessAlert, button: .default(Text("Okay"), action: {
            vm.showSuccessAlert = false
        }))
        .onAppear {
            sessionManager.userData { user in
                vm.user = user
            }
        }
    }
}

