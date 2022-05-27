//
//  LoginView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var vm: AuthRootVM
    
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
                .padding(.top, 16)
            
            //Password TextField
            CustomSecureTextField(text: $vm.password, title: "Password", placeholder: "welcomeview.welcome_content_password_placeholder".localized)
                .padding(.top, 24)
            
            if let error = vm.authServerError {
                serverError(error: error.message)
                    .hLeading()
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
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
            .padding(.top, 27)
            
            Spacer()
            
            //Next Button
            RequestButton(state: $vm.nextButtonState,isDisabled: $vm.nextButtonIsDisabled ,title: "welcomeview.welcome_content_next") {
                vm.userLogin { newUser in
                    if !newUser{
                        UserDefaultsService().set(value: true, forKey: .userIsLogged)
                        sessionManager.userIsLogged = true
                        orderTrackerManager.connect()
                        UserDefaultsService().set(value: false, forKey: .needToFillUserData)
                        sessionManager.needToFillUserData = false
                        coordinatorViewManager.currentRootView = .main
                        tabBarManager.currentTab = .catalog
                        cartManager.getCart()
                    }
                }
            }
            .vBottom()
            .padding(.horizontal, 24)
            .padding(.bottom)
        }
        
    }

    @ViewBuilder
    func serverError(error: String) -> some View {
        HStack(spacing: 8){
            Image(systemName: "xmark" )
                .font(Font.system(size: 10))
                .foregroundColor(.red)
            Text(error)
                .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
        }
    }
    
}
