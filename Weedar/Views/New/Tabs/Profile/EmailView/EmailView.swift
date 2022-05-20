//
//  EmailView.swift
//  Weedar
//
//  Created by Macdudls on 20.05.2022.
//

import SwiftUI
import Amplitude

struct EmailView: View {
    
    @StateObject var vm = EmailVM()
    
    
    var body: some View {
        VStack{
            ScrollView(.vertical, showsIndicators: false) {
                Text("Current email - \(vm.email)")
                    .textSecond()
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .hLeading()
                
                CustomTextField(text: $vm.emailTitle, state: $vm.emailTitleState, title: "New email", placeholder: "Enter your new email")
                    .padding(.top, 24)

                Text("Password")
                    .hLeading()
                    .textCustom(.coreSansC45Regular, 14, Color.col_text_main.opacity(0.7))
                    .padding(.leading, 36)
                    .padding(.top, 12)
                
                ZStack{
                    TextEditor(text: $vm.passwordTitle)
                        .textCustom(.coreSansC45Regular, 16, Color.col_text_main)
                        .padding(.horizontal, 24)
                        .padding(10)
                      //  .frame(height: 342)
                    
                    Text("Enter your password")
                                .textCustom(.coreSansC45Regular, 16, Color.col_text_second.opacity(0.5))
                                .hLeading()
                                .vTop()
                                .padding(.horizontal, 24)
                                .padding(15).padding(.top,3)
                                .opacity(vm.passwordTitle.isEmpty ? 1 : 0)
                }
                
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, showIcon: false, title: "Save") {
                    vm.ChangeEmail()
                    Amplitude.instance().logEvent("change_email")
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .padding(.bottom, 45)
            }
            .navBarSettings("Change email")
            .customErrorAlert(title: "Error", message: vm.errorMessage, isPresented: $vm.showAlert)
        }
    }
}
