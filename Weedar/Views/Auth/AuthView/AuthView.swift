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
    @State var menuTag = 0
    
    
    var body: some View {
        ZStack{
            //color
            Image.bg_gradient_main
                .resizable()
                .frame(width: getRect().width, height: getRect().height / 1.7)
                .edgesIgnoringSafeArea(.all)
                .vTop()
            
            //Top View
            VStack{
                //Logo
                Image.logoDark
                    .resizable()
                    .frame(width: 88, height: 96)
                    .hLeading()
                
                //Title
                Text("Welcom to \nWEEDAR")
                    .hLeading()
                    .textCustom(.coreSansC65Bold, 40, Color.col_text_main)
                    .padding(.top, 12)
                
            }
            .padding(.leading, 24)
            .padding(.top, 49)
            .vTop()
            .hLeading()
            .opacity(isKeyboardShow ? 0 : 1)
            
            VStack{
                //Title
                VStack{
                    Text("Welcom to WEEDAR")
                        .textCustom(.coreSansC65Bold, 24, Color.col_text_main)
                        .hLeading()
                }
                .vBottom()
                .padding(.leading, 24)
                .opacity(isKeyboardShow ? 1 : 0)
                
                CustomPicker()
                
                VStack{
                    switch rootVM.currentPage{
                    case .registration:
                        RegisterView(vm: rootVM)
                            .padding(.top, isKeyboardShow ? 24 : 34)
                        
                    case .login:
                        LoginView(vm: rootVM)
                            .padding(.top, isKeyboardShow ? 24 : 34)
                        
                    }
                }
                .background(
                    Color.col_white
                        .clipShape(CustomCorner(corners: [.topLeft,.topRight], radius: 16))
                        .ignoresSafeArea(.all, edges: .bottom)
                )
                .vBottom()
                .frame(height: getRect().height / 2.2)
            }
        }
        .onChange(of: rootVM.email, perform: { newValue in
            if rootVM.currentPage == .registration{
            if !newValue.isEmpty && rootVM.errors.isEmpty && !rootVM.password.isEmpty{
                rootVM.nextButtonIsDisabled = false
            }else{
                rootVM.nextButtonIsDisabled = true
            }
            }else{
                rootVM.nextButtonIsDisabled = false
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
                    .frame(width: getRect().width / 4, height: 77)
                    .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
                    .transition(.slide)
                    .offset(x: rootVM.currentPage == .registration ? 0 : (getRect().width / 2 + getRect().width / 4) + 5, y: -7)
                
                
                Rectangle()
                    .fill(Color.col_white)
                    .frame(width: getRect().width / 2, height: 77)
                    .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
                    .transition(.slide)
                    .offset(x: rootVM.currentPage == .registration ? 0 : (getRect().width / 2 + 5))
            }
            
            HStack{
                Text("Registration")
                    .textCustom(.coreSansC45Regular, 16, Color.col_black)
                    .frame(width: getRect().width / 2, height: 77)
                    .onTapGesture {
                        withAnimation{
                            rootVM.currentPage = .registration
                            rootVM.nextButtonIsDisabled = true
                        }
                    }
                Spacer()
                Text("Login")
                    .textCustom(.coreSansC45Regular, 16, Color.col_black)
                    .frame(width: getRect().width / 2, height: 77)
                    .onTapGesture {
                        withAnimation {
                            rootVM.currentPage = .login
                            rootVM.nextButtonIsDisabled = false
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
