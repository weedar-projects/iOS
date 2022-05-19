//
//  ResetPasswordView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = ResetPasswordVM()
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
                    .lineLimit(0)
                    .lineSpacing(12)
                    .modifier(TextModifier(font: .coreSansC65Bold, size: 32, foregroundColor: .lightOnSurfaceB, opacity: 1))
                    .padding(.top, 60)
                    .padding(.leading, 24)
                    .hLeading()
                
                //Email Textfield
                CustomTextField(text: $vm.email, state: $vm.emailTFState, title: "resetpasswordview.reset_password_email".localized, placeholder: "resetpasswordview.reset_password_email_placeholder".localized)
                    .hLeading()
                    .padding(.top, 24)
                    .onChange(of: vm.email) { newValue in
                        if !newValue.isEmpty && newValue.isEmailValid{
                            vm.buttonDisabled = false
                        }else{
                            vm.buttonDisabled = true
                        }
                    }
                
                //Error message
                if vm.showError{
                    Text("resetpasswordview.reset_password_error".localized)
                        .lineSpacing(2.4)
                        .padding([.top, .leading], 8)
                        .modifier(TextModifier(font: .coreSansC45Regular, size: 12, foregroundColor: .lightSecondaryB, opacity: 1))
                        .hLeading()
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
