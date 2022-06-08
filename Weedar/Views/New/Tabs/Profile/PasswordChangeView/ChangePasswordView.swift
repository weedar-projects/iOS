//
//  ChangePasswordView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 02.06.2022.
//

import SwiftUI

struct ChangePasswordView: View {
    
    @StateObject var vm = ChangePasswordVM()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack{
            VStack{
                Color.col_white
                    .frame(width: 10, height: 1)
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    
                    //old password
                    CustomSecureTextField(text: $vm.oldPassword, state: $vm.oldPasswordTFState ,title: "Confirm current password", placeholder: "Enter yor password")
                        .padding(.top, 24)
                        .onTapGesture {
                            vm.serverError = ""
                        }
                    
                    
                    Text(vm.serverError)
                        .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
                        .hLeading()
                        .padding(.horizontal, 32)
                    
                    //new password
                    CustomSecureTextField(text: $vm.newPassword, state: $vm.newPasswordTFState ,title: "New password", placeholder: "Confirm new password", contentType: .newPassword)
                        .padding(.top, 24)
                        .onTapGesture {
                            vm.newPasswordTFState = .def
                            vm.showRepeatPasswordError = false
                        }
                    
                    //passowrdError stack
                    if !vm.newPassword.isEmpty{
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()), GridItem(.flexible())
                            ],
                            alignment: .leading,
                            spacing: 0,
                            pinnedViews: [],
                            content: {
                                ForEach(PasswordError.allCases, id:\.self) { item in
                                    errorStackMessage(for: item, isChecked: !vm.errors.contains(item))
                                }
                            })
                        .animation(.linear, value: vm.newPassword.isEmpty)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    
                    //new password repeat
                    CustomSecureTextField(text: $vm.newPasswordRepeat, state: $vm.newPasswordRepeatTFState ,title: "Repeat new password", placeholder: "Confirm your new password", contentType: .newPassword)
                        .padding(.top, 24)
                        .onTapGesture {
                            vm.newPasswordRepeatTFState = .def
                            vm.showRepeatPasswordError = false
                        }
                    
                    Text("Passwords do not match.")
                        .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
                        .hLeading()
                        .padding(.horizontal, 32)
                        .opacity(vm.showRepeatPasswordError ? 1 : 0)
                }
            }
            VStack{
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisable,showIcon: false ,title: "Change password") {
                    if vm.validateRepeatPassword(tapButton: true){
                        sessionManager.userData { user in
                            vm.updatePassword(userID: user.id) {
                                vm.showSuccessAlert = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, isSmallIPhone() ? 16 : 0)
                .vBottom()
            }.ignoresSafeArea(.keyboard, edges: .bottom)
        }
        
        .navBarSettings("Change password")
        .customAlertOneBtn(title: "Congratulations!", message: "Your password is successfully changed.", isPresented: $vm.showSuccessAlert, button: .default(Text("Okay"), action: {
            vm.showSuccessAlert = false
            vm.newPassword = ""
            vm.oldPassword = ""
            vm.newPasswordRepeat = ""
        }))
        
    }
    
    
    @ViewBuilder
    func errorStackMessage(for error: PasswordError, isChecked: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isChecked ? "checkmark" : "xmark" )
                .font(Font.system(size: 10))
                .foregroundColor(isChecked ? Color.col_green_main : Color.col_pink_main)
            
            Text(error.errorMessage.localized)
                .textCustom(.coreSansC45Regular, 14, isChecked ? Color.col_green_main : Color.col_text_second)
        }
        .padding(.bottom, 10)
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}
