//
//  UserIdentificationRootView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI
import Amplitude
import Firebase

struct UserIdentificationRootView: View, KeyboardReadable {
    
    @StateObject var vm: UserIdentificationRootVM
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var coordinatorViewManager: CoordinatorViewManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    
    var body: some View {
        ZStack{
            //color
            Image.bg_gradient_main
                .resizable()
                .frame(width: getRect().width, height: getRect().height / 1.7)
                .edgesIgnoringSafeArea(.all)
                .vTop()
            
            VStack{
                ZStack{
                    Button {
                        vm.backPage {
                            logout()
                        }
                    } label: {
                        //backbutton
                        Image("arrow-back")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.col_black)
                            .frame(width: 14, height: 14)
                            .padding(.top, 5)
                            .padding(.leading, 20)
                    }
                    .hLeading()
                    
                    //nav title
                    Text("Registration")
                        .foregroundColor(Color.col_text_main)
                        .bold()
                        .hCenter()
                        .padding(.top,9)
                }
                .padding(.bottom, -15)
                
                //Page Indicator
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: getRect().width / vm.indicatorValue, height: 35)
                    .foregroundColor(.col_black)
                    .offset(y: 35)
                    .hLeading()
                
            VStack{
                switch vm.currentPage{
                case 0:
                    ProvidePhoneView(vm: vm.providePhoneVM, rootVM: vm)
                case 1:
                    ComfirmPhoneView(vm: vm.comfirmPhoneVM, rootVM: vm)
                case 2:
                    DeliveryDetailsView(vm: vm.deliveryDetailsVM, rootVM: vm)
                case 3:
                    VerifyIdentityView(vm: vm.verifyIdentityVM, rootVM: vm)
                default:
                    Color.clear
                }
            }
            .background(
                Color.lightOnSurfaceA
                    .clipShape(CustomCorner(corners: [.topLeft,.topRight],
                                            radius: 16))
                    .ignoresSafeArea(.all, edges: .bottom)
            )}
            .onChange(of: vm.comfirmPhoneVM.stepSuccess) { val in
                vm.currentPage = val ? 2 : vm.currentPage
            }
            .onChange(of: vm.verifyIdentityVM.stepSuccess) { _ in
                
                print("user loggined")
            }
        }
    }
    
    private func logout() {
//        vm.showLoading = true
        
        FirebaseAuthManager
            .shared
            .signOut { result in
                switch result {
                case .success:
                    
                    orderTrackerManager.disconnect()
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){
                    Amplitude.instance().logEvent("logout_success")
                    }
                    if let _ = UserDefaultsService().get(fromKey: .accessToken){
                        UserDefaultsService().remove(key: .accessToken)
                    }
                    KeychainService.removePassword(serviceKey: .accessToken)
                    
                    UserDefaultsService().set(value: false, forKey: .userVerified)
                    UserDefaultsService().set(value: false, forKey: .userIsLogged)
                    
                    Messaging.messaging().deleteToken { error in
                        if let error = error {
                            print("error to token \(error)")
                        } else {
                            print("debug: token is deleted")
                            print("TOKEN WAS REMOVE")
                            DispatchQueue.main.async {
                                coordinatorViewManager.currentRootView = .auth
                            }
                        }
                    }
                    
                    
                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                }
            }
        
        
    }
}
