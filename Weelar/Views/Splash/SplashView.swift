//
//  SplashView.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 14.09.2021.
//

import SwiftUI

struct SplashView: View {
    // MARK: - Properties
    var duration: Double {
        return isUserAuthorized ? 1.5 : 2.0
    }
    
    @Binding var rootView: RootView
    @State var isUserAuthorized: Bool = false
    @State var isUserUnauthorized: Bool = false

    
    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack {
                // Bckground color
                Color.appBlack
                    .ignoresSafeArea()
                
                // Display next scene
                VStack {
                    NavigationLink(destination: LoginView(rootView: $rootView), isActive: $isUserUnauthorized) {
                        EmptyView()
                    }
                    
                    NavigationLink(destination: LoginView(rootView: $rootView), isActive: $isUserAuthorized) {
                        EmptyView()
                    }
                }
                
                // Background image
                VStack() {
                    NavigationLink(destination: LoginView(rootView: $rootView), isActive: $isUserUnauthorized) {
                        EmptyView()
                    }
                    
                    NavigationLink(destination: LoginView(rootView: $rootView), isActive: $isUserAuthorized) {
                        EmptyView()
                    }
                    
                    Image("splash-background-lines")
                        .resizable()
                        .frame(width: 375, height: 371, alignment: .center)
                    
                    Spacer()
                }
                .zIndex(0)
                .ignoresSafeArea()
                
                // Logos
                VStack() {
                    Image("weel-logo-yellow-circle")
                        .resizable()
                        .frame(width: 174, height: 174, alignment: .center)
                    
                    Spacer()
                    
                    Image("weel-logo-title")
                        .resizable()
                        .frame(width: 162, height: 42, alignment: .center)
                }
                .zIndex(1)
                .padding(.top, 239)
                .padding(.bottom, 100)
                .ignoresSafeArea()
            } // ZStack
        } // NavigationView
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation {
                    self.displayNextScene()
                }
            }
        }
        .opacity(1.0)
        
        /*
        .background(
            // TODO: HIDE AFTER CREATE DESIGN
            Image("splash-mock-background")
                .resizable()
                .frame(width: 375, height: 812, alignment: .center)
                .ignoresSafeArea()
        )
        */
    } // body
}


// MARK: - Custom functions
extension SplashView {
    private func displayNextScene() {
        if UserDefaultsService().get(fromKey: .user) != nil {
            self.isUserUnauthorized = true
        } else {
            self.isUserAuthorized = true
        }
    }
}


// MARK: - PreviewProvider
#if DEBUG
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(rootView: .constant(RootView.loginScreen))
            .previewLayout(.device)
            .previewDevice("iPhone 11 Pro")
    }
}
#endif
