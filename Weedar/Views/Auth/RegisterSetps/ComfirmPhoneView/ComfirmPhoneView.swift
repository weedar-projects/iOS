//
//  ComfirmPhoneView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI


struct ComfirmPhoneView: View {
    
    @StateObject var vm: ComfirmPhoneVM
        
    @StateObject var rootVM: UserIdentificationRootVM
    
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var coordinatorViewManager: CoordinatorViewManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    
    var body: some View{
        VStack{
            
        //title
        Text("Verify your number")
          .lineSpacing(2.8)
          .modifier(TextModifier(font: .coreSansC45Regular, size: 40, foregroundColor: .lightOnSurfaceB, opacity: 1))
          .padding([.top, .leading], 24)
          .hLeading()
       
        //description
            Text("The SMS code is sent to \(vm.phoneNumber)")
            .lineSpacing(2.8)
            .modifier(TextModifier(font: .coreSansC45Regular, size: 14, foregroundColor: .lightOnSurfaceB, opacity: 0.6))
            .padding(.leading, 24)
            .padding(.top, 12)
            .hLeading()
        
        //SMS code (6 digit)
            OTPView(viewModel: vm)
                .padding(.top, 20)
                .onChange(of: vm.otpField.count) { newValue in
                    if newValue == 6{
                        vm.comfirm()
                    }
                }
            
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

        // Resend code
        HStack {
          Text((vm.isResendCodeTimerShow ? "phonenumberview.phone_number_confirm_phone_reminder" : "phonenumberview.phone_number_confirm_phone_question").localized)
            .lineSpacing(2.8)
            .padding(.vertical)
            .modifier(
              TextModifier(font: .coreSansC45Regular,
                           size: 16,
                           foregroundColor: .lightOnSurfaceB,
                           opacity: 0.4)
            )

          Spacer()

          // Show timer
          if vm.isResendCodeTimerShow {
            (Text("phonenumberview.phone_number_confirm_phone_resend".localized)
             +
             Text(" 00:\(String(format: "%02d", vm.secondsLeft))"))
              .lineLimit(1)
              .lineSpacing(4.8)
              .modifier(
                TextModifier(font: .coreSansC65Bold,
                             size: 16,
                             foregroundColor: .lightSecondaryE,
                             opacity: 0.4)
              )
          } else {

            // Resend button
            Button(action: {
              vm.timerStart()
            }) {
              Text("phonenumberview.phone_number_confirm_phone_resend_code".localized)
                .lineLimit(1)
                .lineSpacing(4.8)
                .modifier(
                  TextModifier(font: .coreSansC65Bold,
                               size: 16,
                               foregroundColor: .lightSecondaryE,
                               opacity: 1.0)
                )
            }
          }
        }
        .padding(.horizontal, 24)
            Spacer()
        }
        .onChange(of: vm.stepSuccess) { val in
//            rootVM.currentPage =  2
//            rootVM.updateIndicatorValue()
            print("show onchange register")
            orderTrackerManager.connect()
            UserDefaultsService().set(value: false, forKey: .needToFillUserData)
            sessionManager.needToFillUserData = false
            coordinatorViewManager.currentRootView = .main
        }
        .onAppear {
            vm.errorMessage = ""
            vm.isErrorShow = false
            sessionManager.getUserData {
                vm.userId = sessionManager.user?.id ?? 0
            }
        }
    }
}
