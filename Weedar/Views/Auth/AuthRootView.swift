//
//  AuthRootView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI

struct AuthRootView: View, KeyboardReadable {
    
    @ObservedObject var vm = AuthRootVM()
        
    var body: some View {
        ZStack{
            if vm.showOnboarding{
                OnboardingView(lastPageAction:{
                    print("hide root")
                    vm.showOnboarding = false
                    UserDefaultsService().set(value: false, forKey: .showOnboarding)
                })
            }else{
                AuthView(rootVM: vm)
            }

        }
        .onChange(of: vm.showOnboarding, perform: { newValue in
            print(newValue)
        })
    }
}


