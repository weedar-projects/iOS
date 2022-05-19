//
//  ProfileView.swift
//  Weelar
//
//  Created by vtsyomenko on 24.08.2021.

import SwiftUI

struct ProfileView: View {
    // MARK: - Properties
    @StateObject var viewModel = ProfileViewModel()

    @State private var isPresented = false
    @State private var isActive = false
    @Binding var rootView : RootView
    @State private var loggedOut = false
    @State private var isUserSignOut: Bool = false
    
    
    // MARK: - View
    var body: some View {
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 392)
                    .cornerRadius(radius: 30, corners: .topLeft)
                    .cornerRadius(radius: 12, corners: [.topRight,.bottomLeft, .bottomRight])
                Rectangle()
                    .fill(Color.clear)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 392)
                    .background(Blur(style: .extraLight))
                    .cornerRadius(radius: 30, corners: .topLeft)
                    .cornerRadius(radius: 12, corners: [.topRight,.bottomLeft, .bottomRight])
                    .opacity(0.8)
                VStack(alignment: .leading, spacing: 0) {
                    Image("Back-Navigation-Button")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44, alignment: .center)
                        .onTapGesture {
                            viewModel.profileIsActive = false
                    }
                    Spacer()
                    NavigationLink(destination: OrderView(isActive: $isActive,
                                                          selectedOrderId: $viewModel.selectedOrderId,
                                                          profileIsActive: $viewModel.profileIsActive),
                                   isActive: $viewModel.ordersViewIsActive){
                        HStack(alignment: .center, spacing: 12) {
                            Image("Profile-Orders-Icon")
                                .padding(.trailing, 10)
                                .padding(.leading, 10)
                            Text("Your orders").foregroundColor(ColorManager.Font.darkColor)
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            Image("arrow-right").frame(alignment: .leading).padding(.leading,9)
                        }.frame(height: 56, alignment: .center)
                        .padding([.leading, .trailing],16)
                    }
                    
                    Divider().padding([.leading,.trailing], 16)
                    NavigationLink(destination:DeliveryDetailsView(cartViewModel: CartViewModel(),
                                                                   profileIsActive: $viewModel.profileIsActive,
                                                                   isProfile: true)){
                        HStack(alignment: .center, spacing: 12) {
                            Image("Profile-Delivery-Icon")
                                .padding(.trailing, 10)
                                .padding(.leading, 10)
                            Text("Delivery details").foregroundColor(ColorManager.Font.darkColor)
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            Image("arrow-right").frame(alignment: .leading).padding(.leading,9)
                        }.frame(height: 56, alignment: .center)
                        .padding([.leading, .trailing],16)
                    }
                    
                    Divider().padding([.leading,.trailing], 16)
                    NavigationLink(destination:SettingsView(profileIsActive: $viewModel.profileIsActive)){
                        HStack(alignment: .center, spacing: 12) {
                            Image("Profile-Settings-Icon")
                                .padding(.trailing, 10)
                                .padding(.leading, 10)
                            Text("Settings").foregroundColor(ColorManager.Font.darkColor)
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            Image("arrow-right").frame(alignment: .leading)
                                .padding(.leading,9)
                        }.frame(height: 56, alignment: .center)
                        .padding([.leading, .trailing],16)
                    }
                    
                    Divider().padding([.leading,.trailing], 16)
                    NavigationLink(destination:SupportView(isSendMessage: $viewModel.isSendMessage, profileIsActive: $viewModel.profileIsActive)){
                        HStack(alignment: .center, spacing: 12) {
                            Image("Profile-ContactUs-Icon")
                                .padding(.trailing, 10)
                                .padding(.leading, 10)
                            Text("Contact us")
                                .foregroundColor(ColorManager.Font.darkColor)
                                .font(.system(size: 14))
                                .bold()
                            Spacer()
                            Image("arrow-right")
                                .frame(alignment: .leading)
                                .padding(.leading,9)
                        }.frame(height: 56, alignment: .center)
                        .padding([.leading, .trailing],16)
                    }
                    
                    ZStack {
                        Button(action: {
                            ProductsViewModel.shared.products = []
                            KeychainService.removePassword(serviceKey: .accessToken)
                            
                            FirebaseAuthManager.shared.signOut { result in
                                switch result {
                                case .success:
                                    isUserSignOut.toggle()
                                    viewModel.profileIsActive = false
                                    UserDefaultsService().remove(key: .userVerified)

                                case .failure(let error):
                                    Logger.log(message: error.localizedDescription, event: .error)
                                }
                            }
                        }, label: {
                            Text("Log Out")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .bold()
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight:0, maxHeight: .infinity, alignment: .center)
                        })
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 54)
                            .background(ColorManager.errorColor)
                            .cornerRadius(10.0)
                            .padding(.top, 24)
                    }
                    .padding([.leading, .trailing, .bottom], 16)
                }
            }
            .navigationBarHidden(true)
            .background(Color.clear)
            .frame(height: 392)
//            .onDisappear {
//                if loggedOut {
//                    UserDefaultsService().remove(key: .user)
//                }
//            }
            .fullScreenCover(isPresented: $isUserSignOut, content: {
                SplashView(rootView: $rootView)
            })
    } // body
}
