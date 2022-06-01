//
//  LoginView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var vm: AuthRootVM
    @Binding var keyboardIsShow: Bool
    @EnvironmentObject var coordinatorViewManager: CoordinatorViewManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    @EnvironmentObject var cartManager: CartManager
    var body: some View {
        VStack{
            //Email TextField
            CustomTextField(text: $vm.email, state: $vm.emailTFState, title: "Email", placeholder: "welcomeview.welcome_content_email_placeholder".localized)
                .keyboardType(.emailAddress)
            
            //Password TextField
            CustomSecureTextField(text: $vm.password, state: $vm.passwordTFState ,title: "Password", placeholder: "welcomeview.welcome_content_password_placeholder".localized)
                .padding(.top, 24)
            
            if let error = vm.authServerError {
                serverError(error: error.message)
                    .hLeading()
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                    .padding(.leading, 7)
            }
            //ResetPassword Button
            Button(action: {
                withAnimation {
                    vm.isResetPasswordSheetShow = true
                }
            }) {
                Text("welcomeview.welcome_content_reset_password".localized)
                    .modifier(
                        TextModifier(font: .coreSansC65Bold,
                                     size: 16,
                                     foregroundColor: .col_text_main,
                                     opacity: 1.0)
                    )
            }
            .padding(.top, 16)
            
            Spacer()
            
            //Next Button
            RequestButton(state: $vm.nextButtonState,isDisabled: $vm.nextButtonIsDisabled ,title: "welcomeview.welcome_content_next") {
                vm.userLogin { needToFillData in
                    
                    sessionManager.userData(withUpdate: true)
                    if needToFillData{
                        sessionManager.needToFillUserData = true
                        sessionManager.userIsLogged = true
                        coordinatorViewManager.currentRootView = .registerSetps
                        UserDefaultsService().set(value: true, forKey: .needToFillUserData)
                        UserDefaultsService().set(value: true, forKey: .userIsLogged)
                        cartManager.getCart()
                        
                    }else{
                        UserDefaultsService().set(value: true, forKey: .userIsLogged)
                        sessionManager.userIsLogged = true
                        orderTrackerManager.connect()
                        sessionManager.needToFillUserData = false
                        UserDefaultsService().set(value: false, forKey: .needToFillUserData)
                        coordinatorViewManager.currentRootView = .main
                        tabBarManager.currentTab = .catalog
                        cartManager.getCart()
                    }
  
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom)
            .offset(y: keyboardIsShow ? -18 : 0)
        }
        
    }

    @ViewBuilder
    func serverError(error: String) -> some View {
        HStack(spacing: 8){
            Image(systemName: "xmark" )
                .font(Font.system(size: 10))
                .foregroundColor(Color.col_pink_main)
            
            Text(error)
                .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
        }
    }
    
}
