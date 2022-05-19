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
                ZStack{
                    if vm.showOnboardingSecondView{
                        //2
                        StartView(title: "startview.location.confirm.title".localized,
                                  subTitle: "startview.location.confirm.subtitle".localized,
                                  description: nil,
                                  leaveButtonTitle: "startview.location.leave_no".localized,
                                  enterButtonTitle: "startview.location.enter_yes".localized,
                                  isLastViewForConfirmation: true,
                                  showOnboardingSecondView: $vm.showOnboardingSecondView,
                                  showOnboarding: $vm.showOnboarding)
                        
                    } else {
                        //1
                        StartView(title: "startview.age.confirm.title".localized,
                                  subTitle: "startview.age.confirm.subtitle".localized,
                                  description: "startview.age.confirm.description".localized,
                                  leaveButtonTitle: "startview.leave_btn".localized,
                                  enterButtonTitle: "startview.enter_btn".localized,
                                  isLastViewForConfirmation: false,
                                  showOnboardingSecondView: $vm.showOnboardingSecondView,
                                  showOnboarding: $vm.showOnboarding)
                        
                    }
                }
            }else{
                AuthView(rootVM: vm)
            }

        }
        .onChange(of: vm.showOnboarding, perform: { newValue in
            print(newValue)
        })
    }
}


