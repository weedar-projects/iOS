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

                CustomTextField(text: $vm.passwordTitle, state: $vm.passwordTitleState, title: "Password", placeholder: "Enter your password")
                    .padding(.top, 24)
                
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, showIcon: false, title: "Save") {
                    vm.ChangeEmail()
                    Amplitude.instance().logEvent("change_email")
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .padding(.bottom, 45)
            }
            .customErrorAlert(title: "Error", message: vm.errorMessage, isPresented: $vm.showAlert)
        }
    }
}
