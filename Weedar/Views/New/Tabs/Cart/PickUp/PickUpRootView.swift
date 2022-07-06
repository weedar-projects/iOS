//
//  PickUpRootView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.06.2022.
//

import SwiftUI
import MapKit
import SwiftyJSON
import Introspect

struct PickUpRootView: View {
    @StateObject var vm = PickUpRootVM()
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.presentationMode) var presentationMode
    @Namespace var bottomID
    var body: some View {
        ZStack{
            NavigationLink(isActive: $vm.showRaduisPicker) {
                GeolocationSelectView(selectedRadius: $vm.selectedRadius)
            } label: {
                Color.clear
            }.isDetailLink(false)
            Color.col_white
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                PickUpShopListPiker(selected: $vm.selectedTab)
                    .padding(.top, 24)
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { reader in
                        VStack{
                            Text("My address:")
                                .textSecond()
                                .padding(.horizontal, 24)
                                .hLeading()
                                .padding(.top, 17)
                            HStack{
                                Text(vm.address)
                                    .textDefault()
                                    .padding(.leading, 24)
                                    .padding(.trailing, 10)
                                    .hLeading()
                                
                                Image("edit_icon2")
                                    .padding(.trailing, 24)
                            }
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.top, 21)
                            
                            RadiusSelectBtn()
                                .padding(.top, 15)
                                .onTapGesture {
                                    vm.showRaduisPicker = true
                                }
                            
                            Text("Stores available: \(vm.availableStoresList.count)")
                                .textSecond()
                                .padding([.horizontal,.top], 24)
                                .hLeading()
                            
                            if vm.selectedTab == .list{
                                PickUpListView(rootVM: vm)
                                    .transition(.fade)
                            }else{
                                
                                PickUpMapView(rootVM: vm)
                            }
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 10, height: 1)
                                .id(bottomID)
                        }
                        .onChange(of: vm.selectedStore?.id) { newValue in
                            reader.scrollTo(bottomID)
                        }
                    }
                }
                
                Spacer()
            }
            
            if vm.showStoreInfo{
                Color.col_black
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.fade)
                    .onTapGesture {
                        withAnimation {
                            vm.showStoreInfo = false
                        }
                    }
                
                StoreInfo(rootVM: vm)
                    .transition(.move(edge: .bottom))
            }
        }
        .navBarSettings("Select a store")
        .onAppear{
            sessionManager.userData(withUpdate: true) { user in
                vm.userData = user
                vm.getStores(radius: vm.selectedRadius)
            }
        }
        .actionSheet(isPresented: $vm.showDirectionsView) {
            ActionSheet(title: Text("Select app"),
                        buttons: [
                            .default(
                                Text("Google Maps")
                                    .foregroundColor(Color.lightSecondaryE.opacity(1.0))
                                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            ) {
                                guard let store = vm.selectedStore else {return}
                                Utils.shared.openGoogleMap(address: store.address,lat: store.latitudeCoordinate, lon: store.longitudeCoordinate)
                            },
                            .default(
                                Text("Apple Maps")
                                    .foregroundColor(Color.lightSecondaryE.opacity(1.0))
                                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            ) {
                                guard let store = vm.selectedStore else {return}
                                Utils.shared.openAppleMap(address: store.address,lat: store.latitudeCoordinate, lon: store.longitudeCoordinate)
                            },
                            .cancel()
                        ])
        }
        .customErrorAlert(title: "Ooops", message: vm.alertMessage, isPresented: $vm.showerrorAlert)
        .introspectNavigationController { navigationController in
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    
    @ViewBuilder
    func RadiusSelectBtn() -> some View{
        
        HStack(spacing: 0){
            Image("mapMarker_icon")
                .scaleEffect(0.8)
                .padding(.leading , 16)
            
            Text("Within \(vm.selectedRadius.formattedString(format: .int)) miles")
                .textCustom(.coreSansC45Regular, 16, Color.col_text_main)
            Spacer()
            Image("arrowRight")
                .padding(.trailing , 16)
        }
        .padding(.horizontal, 24)
        .frame(height: 48)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder()
                .frame(height: 48)
                .foregroundColor(Color.col_gray_main)
                .padding(.horizontal, 24)
        )
        
    }
}



enum PickUpShopListState{
    case list
    case map
}
