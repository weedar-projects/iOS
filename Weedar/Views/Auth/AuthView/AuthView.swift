//
//  AuthView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 10.03.2022.
//

import SwiftUI

struct AuthView: View, KeyboardReadable {
    
    @StateObject var rootVM: AuthRootVM
    
    @State var isKeyboardShow: Bool = false
    
    var body: some View {
        ZStack{
            //color
            Image.bg_gradient_main
                .resizable()
                .frame(width: getRect().width, height: getRect().height / 1.7)
                .edgesIgnoringSafeArea(.all)
                .vTop()
            
            //Top View
            VStack(spacing: 0){
                //Logo
                Image.logoDark
                    .resizable()
                    .frame(width: 88, height: 96)
                    .hLeading()
                
                //Title
                Text("Welcome to")
                    .hLeading()
                    .textCustom(.coreSansC55Medium, 36, Color.col_text_main)
                    .padding(.top, 18)
                
                Text("\nWEEDAR")
                    .hLeading()
                    .textCustom(.coreSansC65Bold, 52, Color.col_text_main)
                    .offset(y: isSmallIPhone() ? -55 : -40)
                
            }
            .padding(.leading, 24)
            .padding(.top, 49)
            .vTop()
            .hLeading()
            .opacity(isKeyboardShow ? 0 : 1)
            
            VStack{
                //Title
                VStack{
                    Text("Welcome to WEEDAR")
                        .textCustom(.coreSansC65Bold, 24, Color.col_text_main)
                        .hLeading()
                        .opacity(isSmallIPhone() ? 0 : 1)
                }
                .vBottom()
                .padding(.leading, 24)
                .opacity(isKeyboardShow ? 1 : 0)
                
                CustomPicker()
                
                VStack(spacing: 0){
                    switch rootVM.currentPage{
                    case .registration:
                        RegisterView(vm: rootVM, keyboardIsShow: $isKeyboardShow)
                            .padding(.top, 30)
                        
                        
                    case .login:
                        LoginView(vm: rootVM, keyboardIsShow: $isKeyboardShow)
                            .padding(.top, 30)
                        
                    }
                }
                .background(
                    Color.col_white
                        .clipShape(CustomCorner(corners: [.topLeft,.topRight], radius: 16))
                        .ignoresSafeArea(.all, edges: .bottom)
                )
                .vBottom()
                .frame(height: getRect().height / (isSmallIPhone() ? 2 : 2.3))
            }
        }
        .onChange(of: rootVM.email, perform: { newValue in
            if rootVM.currentPage == .registration{
                if !newValue.isEmpty && rootVM.errors.isEmpty && !rootVM.password.isEmpty{
                    rootVM.nextButtonIsDisabled = false
                }else{
                    rootVM.nextButtonIsDisabled = true
                }
            }
        })
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            withAnimation(.linear){
                isKeyboardShow = newIsKeyboardVisible
            }
        }
        .sheet(isPresented: $rootVM.isResetPasswordSheetShow, content: {
          ResetPasswordView()
        })
    }
    
    @ViewBuilder
    func CustomPicker() -> some View {
        ZStack(alignment: .leading){
            ZStack(alignment: .leading){
                Rectangle()
                    .fill(Color.col_black)
                    .frame(width: getRect().width / 3, height: 61)
                    .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
                    .transition(.slide)
                    .offset(x: rootVM.currentPage == .registration ? 0 : (getRect().width / 2 + getRect().width / 6) + 5, y: -7)
                
                
                Rectangle()
                    .fill(Color.col_white)
                    .frame(width: getRect().width / 2, height: 61)
                    .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
                    .transition(.slide)
                    .offset(x: rootVM.currentPage == .registration ? 0 : (getRect().width / 2 + 5))
            }
            
            HStack{
                Text("Registration")
                    .textCustom(rootVM.currentPage == .registration ? .coreSansC65Bold : .coreSansC45Regular, 16, Color.col_black)
                    .frame(width: getRect().width / 2, height: 61)
                    .onTapGesture {
                        withAnimation{
                            rootVM.currentPage = .registration
                            rootVM.nextButtonIsDisabled = true
                        }
                    }
                Spacer()
                
                Text("Login")
                    .textCustom(rootVM.currentPage == .login ? .coreSansC65Bold : .coreSansC45Regular, 16, Color.col_black)
                    .frame(width: getRect().width / 2, height: 61)
                    .onTapGesture {
                        withAnimation {
                            rootVM.currentPage = .login
                        }
                    }
            }
        }
        .offset(y: 16)
    }
}

enum AuthViewPages{
    case registration
    case login
}
