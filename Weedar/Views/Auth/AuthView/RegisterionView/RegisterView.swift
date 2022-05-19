//
//  RegisterView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject var vm: AuthRootVM
    
    @EnvironmentObject var coordinatorViewManager: CoordinatorViewManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var sessionManager: SessionManager
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
            .onChange(of: vm.password) { newValue in
                vm.validatePassword(newValue)
            }
            
        if vm.errors.isEmpty, let error = vm.authServerError {
            
            //server Error
            serverError(error: error.message)
                .hLeading()
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.horizontal, 24)
            
        } else if !vm.password.isEmpty{
            //passowrdError stack
            LazyVGrid(
                columns: [
                    GridItem(.flexible()), GridItem(.flexible())
                ],
                alignment: .leading,
                spacing: 0,
                pinnedViews: [],
                content: {
                    ForEach(AuthRootVM.PasswordError.allCases, id:\.self) { item in
                        errorStackMessage(for: item, isChecked: !vm.errors.contains(item))
                    }
                })
                .animation(.linear, value: vm.password.isEmpty)
                .padding(.horizontal, 24)
                .padding(.top, 8)
        }
        
            Spacer()
        
        //Next Button
        RequestButton(state: $vm.nextButtonState,isDisabled: $vm.nextButtonIsDisabled ,title: "welcomeview.welcome_content_next") {
            vm.userRegister {
                //if new user open register steps view
                vm.userLogin(asNewUser: true) { newUser in
                    if newUser{
                        UserDefaultsService().set(value: true, forKey: .userIsLogged)
                        sessionManager.userIsLogged = true
                        UserDefaultsService().set(value: true, forKey: .needToFillUserData)
                        sessionManager.needToFillUserData = true
                        coordinatorViewManager.currentRootView = .registerSetps
                        tabBarManager.currentTab = .catalog
                        cartManager.getCart()
                    }
                }
            }
        }
        .vBottom()
        .padding(.bottom)
        .padding(.horizontal, 24)
    }
    
    }
    @ViewBuilder
    func errorStackMessage(for error: AuthRootVM.PasswordError, isChecked: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isChecked ? "checkmark" : "xmark" )
                .font(Font.system(size: 10))
                .foregroundColor(isChecked ? .lightSecondaryF : .red)
            Text(error.errorMessage.localized)
                .modifier(
                    TextModifier(font: .coreSansC45Regular,
                                 size: 14,
                                 foregroundColor: isChecked ? .lightSecondaryF : .lightSecondaryB,
                                 opacity: 1.0)
                )
        }
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    func serverError(error: String) -> some View {
        HStack(spacing: 8){
        Image(systemName: "xmark" )
            .font(Font.system(size: 10))
            .foregroundColor(.red)
        Text(error)
            .modifier(
                TextModifier(font: .coreSansC45Regular,
                             size: 14,
                             foregroundColor: .lightSecondaryB,
                             opacity: 1.0)
            )
        }
    }
}
