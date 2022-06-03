//
//  RegisterView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI

struct RegisterView: View {
    
    @StateObject var vm: AuthRootVM
    
    @Binding var keyboardIsShow: Bool
    @EnvironmentObject var coordinatorViewManager: CoordinatorViewManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack{
            //Email TextField
            CustomTextField(text: $vm.email, state: $vm.emailTFState,title: "Email", placeholder: "welcomeview.welcome_content_email_placeholder".localized, keyboardType: .emailAddress, contentType: .username)
                .onTapGesture {
                    if let _ = vm.authServerError {
                        vm.authServerError = nil
                    }
                }
            
            //Password TextField
            CustomSecureTextField(text: $vm.password, state: $vm.passwordTFState,title: "Password", placeholder: "welcomeview.welcome_content_password_placeholder".localized)
                .padding(.top, 24)
                .onTapGesture {
                    if let _ = vm.authServerError {
                        vm.authServerError = nil
                    }
                }
                .onChange(of: vm.password) { newValue in
                    vm.validatePassword(newValue)
                }
            
            if vm.errors.isEmpty, let error = vm.authServerError {
                //server Error
                serverError(error: error.message)
                    .hLeading()
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                    .padding(.leading, 7)
                
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
                        ForEach(PasswordError.allCases, id:\.self) { item in
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
                    vm.userLogin { needToFillData in
                        sessionManager.userData(withUpdate: true)
                        if needToFillData{
                            sessionManager.needToFillUserData = true
                            sessionManager.userIsLogged = true
                            coordinatorViewManager.currentRootView = .registerSetps
                            UserDefaultsService().set(value: true, forKey: .needToFillUserData)
                            UserDefaultsService().set(value: true, forKey: .userIsLogged)
                            cartManager.getCart()
                        }
                    }
                }
            }
            .vBottom()
            .padding(.bottom)
            .padding(.horizontal, 24)
            .offset(y: keyboardIsShow && !isSmallIPhone() ? -18 : 0)
        }
        
    }
    @ViewBuilder
    func errorStackMessage(for error: PasswordError, isChecked: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isChecked ? "checkmark" : "xmark" )
                .font(Font.system(size: 10))
                .foregroundColor(isChecked ? Color.col_green_main : Color.col_pink_main)
            
            Text(error.errorMessage.localized)
                .textCustom(.coreSansC45Regular, 14, isChecked ? Color.col_green_main : Color.col_text_second)
        }
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    func serverError(error: String) -> some View {
        HStack(spacing: 8){
            Image(systemName: "xmark" )
                .font(Font.system(size: 10))
                .foregroundColor(Color.col_pink_button)
            Text(error)
                .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
        }
    }
}
