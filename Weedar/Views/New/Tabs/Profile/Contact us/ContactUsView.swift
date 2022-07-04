//
//  ContactUsView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 12.04.2022.
//

import SwiftUI
 

struct ContactUsView: View {
    
    @StateObject var vm = ContactUsVM()
    
    var body: some View {
        VStack{
            ScrollView(.vertical, showsIndicators: false) {
                Text("If you have any troubles with using service, suggestions or something you would like to share place use form below to tell us. We will send you reply via email")
                    .textSecond()
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .hLeading()
                
                CustomTextField(text: $vm.messageTitle, state: $vm.messageTitleState, title: "Title", placeholder: "Message title")
                    .padding(.top, 24)
                    .onChange(of: vm.messageTitle) { _ in
                        vm.validateButton()
                    }
                Text("Message")
                    .hLeading()
                    .textCustom(.coreSansC45Regular, 14, Color.col_text_main.opacity(0.7))
                    .padding(.leading, 36)
                    .padding(.top, 12)
                
                ZStack{
                    TextEditor(text: $vm.messageText)
                        .textCustom(.coreSansC45Regular, 16, Color.col_text_main)
                        .padding(.horizontal, 24)
                        .padding(10)
                        .frame(height: 342)
                    
                    Text("Enter your message")
                                .textCustom(.coreSansC45Regular, 16, Color.col_text_second.opacity(0.5))
                                .hLeading()
                                .vTop()
                                .padding(.horizontal, 24)
                                .padding(15).padding(.top,3)
                                .opacity(vm.messageText.isEmpty ? 1 : 0)
                }
                .overlay( RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.col_borders, lineWidth: 2)
                            .padding(.horizontal, 24)
                )
                .onChange(of: vm.messageText) { _ in
                    vm.validateButton()
                }
                
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, showIcon: false, title: "Send") {
                    vm.sendMessage()
                    AnalyticsManager.instance.event(key: .send_message)
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .padding(.bottom, 45)
            }
            .navBarSettings("Contact us")
            .customErrorAlert(title: "Ooops", message: vm.errorMessage, isPresented: $vm.showAlert)
        }
    }
}
