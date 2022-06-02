//
//  ChangePhoneView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 03.06.2022.
//

import SwiftUI

struct ChangePhoneView: View {
    
    @StateObject var vm = ChangePhoneVM()
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack{
            NavigationLink("", isActive: $vm.showOTPView) {
                ComfirmChangePhoneView(veritificationID: $vm.verificationID, phone: $vm.phoneEntered)
            }.isDetailLink(false)
            VStack{
                //description
                if let phone = sessionManager.user?.phone{
                    Text("Current phone number \(format(with: "+X (XXX) XXX-XXXXXX", phone: phone))")
                        .textSecond()
                        .padding(.leading, 24)
                        .padding(.top, 12)
                        .hLeading()
                }
                
                // Phone number titlte
                Text("New phone number")
                    .textCustom(.coreSansC45Regular, 14, Color.col_text_second)
                    .hLeading()
                    .padding(.top, 24)
                    .padding(.leading, 36)
                
                //phon number textfield
                HStack{
                    Text("\(vm.phoneEntered.countryFlag)")
                        .frame(width: 24, height: 24)
                        .padding(.leading, 14)
                    
                    ZStack{
                        if vm.phoneEntered == "+1"{
                            Text("(000) 000-0000")
                                .textCustom(.coreSansC45Regular, 16, Color.col_text_second.opacity(0.8))
                                .hLeading()
                                .padding(.leading,22)
                                .offset(y: 2)
                        }
                        
                        TextField("", text: $vm.phoneEntered)
                            .keyboardType(.phonePad)
                            .disableAutocorrection(true)
                    }
                    .onChange(of: vm.phoneEntered) { newValue in
                        vm.phoneEntered = format(with: "+X (XXX) XXX-XXXXXX", phone: newValue)
                    }
                }
                .overlay(
                    //color
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.col_borders, lineWidth: 2)
                        .frame(height: 48, alignment: .leading)
                    
                )
                .padding(.horizontal, 24)
                .padding(.top)
                .padding(.bottom, 10)
                
                // Error Message
                if vm.isErrorShow {
                    Text(vm.errorMessage)
                        .textCustom(.coreSansC45Regular, 12, Color.col_pink_main)
                        .hLeading()
                        .padding(.horizontal, 36)
                        .padding(.top, 6)
                }
                
                Spacer()
                
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, title: "Next") {
                    vm.sendPhoneAuthentication()
                }
                .padding(.horizontal, 24)
                .padding(.bottom)
                .onChange(of: vm.phoneEntered) { newValue in
                    if newValue.count < 3{
                        vm.buttonIsDisabled  = true
                    }else{
                        vm.buttonIsDisabled  = false
                    }
                }
            }
        }
        
    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
}
