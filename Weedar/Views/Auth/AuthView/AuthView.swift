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
            Color.lightOnSurfaceB
                .edgesIgnoringSafeArea(.all)
            
            //imgage
            Image("splash-background-lines")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3, alignment: .top)
                .opacity(0.5)
                .edgesIgnoringSafeArea(.top)
                .vTop()
                
            //Top View
            VStack{
                //Logo
                Image("logo_new")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .hLeading()
                
                //Title
                Text(String(format: "%@%@%@", "welcomeview.welcome_welcome".localized, "\n", "welcomeview.welcome_to_weel".localized))
                    .hLeading()
                    .textCustom(.coreSansC65Bold, 40, Color.col_white)
                
                //Description
//                Text(menuTag == 0 ? "Sign up to create your account." : "Sign in to continue to your account.")
//                    .hLeading()
//                    .padding(.top)
//                    .textCustom(.coreSansC45Regular, 16, Color.col_white.opacity(0.5))
                    
            }
            .padding(.leading, 24)
            .vTop()
            .hLeading()
            .opacity(isKeyboardShow ? 0 : 1)
            
            VStack{
                //Title
                VStack{
                    
                    Text(String(format: "%@%@%@", "welcomeview.welcome_welcome".localized, " ","welcomeview.welcome_to_weel".localized))
                        .textCustom(.coreSansC65Bold, 24, Color.col_white)
                        .hLeading()
     
                    
//                    Description
//                    Text(menuTag == 0 ? "Sign up to create your account." : "Sign in to continue to your account.")
//                        .textCustom(.coreSansC45Regular, 16, Color.col_white.opacity(0.5))
//                        .padding(.top, 7)
//                        .hLeading()
                }
                .vBottom()
                .padding(.leading, 24)
                .opacity(isKeyboardShow ? 1 : 0)
                
                
            VStack{
                //Picker
                Picker(selection: $menuTag) {

                    Text("Registration")
                      .modifier(
                        TextModifier(font: .coreSansC65Bold,
                                     size: 14,
                                     foregroundColor: .black,
                                     opacity: 1)
                      )
                      .tag(0)
                    Text("Login")
                      .modifier(
                        TextModifier(font: .coreSansC65Bold,
                                     size: 14,
                                     foregroundColor: .black,
                                     opacity: 1)
                      )
                      .tag(1)
                    
                } label: {
                    Color.clear
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 16)
                .padding(.horizontal, 24)
                
                TabView(selection: $menuTag){
                    RegisterView(vm: rootVM)
                        .onAppear {
                            rootVM.authServerError = nil
                            rootVM.password = ""
                        }
                        .tag(0)
                    
                    LoginView(vm: rootVM)
                        .onAppear {
                            rootVM.authServerError = nil
                            rootVM.password = ""
                        }.tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
            }
            .background(
                Color.lightOnSurfaceA
                    
                    .clipShape(CustomCorner(corners: [.topLeft,.topRight], radius: 16))
                    .ignoresSafeArea(.all, edges: .bottom)
            )
            .vBottom()
            .frame(height: getRect().height / 2)
            }
        }
        .onChange(of: rootVM.email, perform: { newValue in
            if !newValue.isEmpty{
                rootVM.nextButtonIsDisabled = false
            }else{
                rootVM.nextButtonIsDisabled = true
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
}
