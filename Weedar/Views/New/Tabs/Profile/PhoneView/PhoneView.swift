//
//  PhoneView.swift
//  Weedar
//
//  Created by Macdudls on 20.05.2022.
//

import SwiftUI

struct PhoneView: View {
    
    @StateObject var vm = PhoneVM()
    
    var body: some View{
        
        //description
        Text("Current phone \(vm.phone)")
            .textSecond()
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .hLeading()
        

        // Phone number titlte
        Text("phonenumberview.phone_number_provide_phone_number".localized)
          .modifier(TextModifier(font: .coreSansC45Regular, size: 14, foregroundColor: .lightOnSurfaceB, opacity: 0.7))
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
                .lineSpacing(2.8)
                .modifier(
                    TextModifier(font: .coreSansC45Regular,
                                 size: 12,
                                 foregroundColor: .lightSecondaryB,
                                 opacity: 1.0)
                )
                .hLeading()
                .padding(.horizontal, 36)
                .padding(.top, 6)
        }
        
        
        Spacer()
        
        RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, title: "welcomeview.welcome_content_next".localized) {
            vm.sendPhoneAuthentication()
            UserDefaultsService().set(value: vm.phoneEntered, forKey: .phone)
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
        .onChange(of: vm.stepSuccess) { val in
            
            print("next")
//            rootVM.currentPage += 1
//            rootVM.comfirmPhoneVM.verificationID = rootVM.providePhoneVM.verificationID
//            rootVM.comfirmPhoneVM.phoneNumber = vm.phoneEntered
//            rootVM.updateIndicatorValue()
//            rootVM.comfirmPhoneVM.otpField = ""
//            vm.buttonState = .def
        }
        .onAppear {
//            if rootVM.comfirmPhoneVM.verificationID != ""{
//                vm.stepSuccess = true
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
