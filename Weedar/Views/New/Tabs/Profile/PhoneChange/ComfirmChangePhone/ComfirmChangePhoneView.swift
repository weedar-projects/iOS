//
//  ComfirmChangePhoneView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 03.06.2022.
//

import SwiftUI

struct ComfirmChangePhoneView: View {
    
    @StateObject var vm = ComfirmChangePhoneVM()
    @Binding var veritificationID: String
    @Binding var phone: String
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.presentationMode) var mode 
    
    var successAction: () -> Void
    
    var body: some View{
        ZStack{
        VStack{
            //description
            Text("The SMS code is sent to \(vm.phoneNumber)")
                .textCustom(.coreSansC45Regular, 14, Color.col_text_second)
                .padding(.leading, 24)
                .padding(.top, 12)
                .hLeading()
            
            //SMS code (6 digit)
            OTPViewChange(viewModel: vm)
                .padding(.top, 20)
                .onChange(of: vm.otpField.count) { newValue in
                    if newValue == 6{
                        vm.comfirm()
                    }
                }
            
            // Error Message
            if vm.isErrorShow {
                Text(vm.errorMessage)
                    .textCustom(.coreSansC45Regular, 12, Color.col_pink_main)
                    .hLeading()
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
            }
            
            // Resend code
            HStack {
                Text((vm.isResendCodeTimerShow ? "phonenumberview.phone_number_confirm_phone_reminder" : "phonenumberview.phone_number_confirm_phone_question").localized)
                    .textCustom(.coreSansC45Regular, 16, Color.col_text_second)
                    .padding(.vertical)
                
                Spacer()
                
                // Show timer
                if vm.isResendCodeTimerShow {
                    (Text("phonenumberview.phone_number_confirm_phone_resend".localized)
                     +
                     Text(" 00:\(String(format: "%02d", vm.secondsLeft))"))
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                } else {
                    // Resend button
                    Button(action: {
                        vm.timerStart()
                        vm.otpField = ""
                    }) {
                        Text("phonenumberview.phone_number_confirm_phone_resend_code".localized)
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .customAlertOneBtn(title: "Congratulations!", message: "Your phone is successfully changed.", isPresented: $vm.showSuccessAlert, button: .default(Text("Okay"), action: {
            vm.showSuccessAlert = false
            mode.wrappedValue.dismiss()
            successAction()
        }))
        }
        .navBarSettings("Confirm your number")
        .onAppear {
            vm.verificationID = veritificationID
            vm.phoneNumber = phone
            vm.errorMessage = ""
            vm.isErrorShow = false
            sessionManager.userData { user in
                vm.userId = user.id
            }
        }
    }
}
