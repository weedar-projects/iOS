//
//  ResetPasswordView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm = ResetPasswordVM()
    
    var body: some View {
        ZStack{
            //bg color
            Color.lightOnSurfaceA
                .ignoresSafeArea()
            
                //xmark Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image("reset-password-close")
                    .frame(width: 24, height: 24, alignment: .center)
            })
                .vTop()
                .hTrailing()
                .padding(8)
            
            VStack{
                //Title
                Text("resetpasswordview.reset_password_reset_password".localized)
                    .modifier(TextModifier(font: .coreSansC65Bold, size: 32, foregroundColor: .lightOnSurfaceB, opacity: 1))
                    .padding(.top, 60)
                    .padding(.leading, 24)
                    .hLeading()
                
                //Email Textfield
                CustomTextField(text: $vm.email,
                                state: $vm.emailTFState,
                                title: "resetpasswordview.reset_password_email".localized,
                                placeholder: "resetpasswordview.reset_password_email_placeholder".localized,
                                keyboardType: .emailAddress,
                                contentType: .emailAddress)
                    .hLeading()
                    .padding(.top, 24)
                    .onTapGesture {
                        vm.errorAPI = nil
                    }
                
                //Error message
                if let messadge = vm.errorAPI?.message{
                    Text(messadge)
                        .padding([.top, .leading], 8)
                        .modifier(TextModifier(font: .coreSansC45Regular, size: 14, foregroundColor: Color.col_pink_main, opacity: 1))
                        .hLeading()
                        .padding(.horizontal, 24)
                }
                
                //Reset password Button
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonDisabled, title: "resetpasswordview.reset_password_reset_password".localized) {
                    vm.resetPassword()
                }
                .vBottom()
                .padding(.bottom, 8)
                .padding(.horizontal, 24)
                
            }
            .vTop()
            
        }
        .alert(isPresented: $vm.isAlertShow) {
            Alert(title:
                    Text("resetpasswordview.reset_password_alert_title".localized),
                  message:
                    Text("resetpasswordview.reset_password_alert_message".localized),
                  dismissButton:
                        .default(
                            Text("resetpasswordview.reset_password_alert_action_button".localized),
                            action: {
                                presentationMode.wrappedValue.dismiss()
                            }
                        )
            )
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
