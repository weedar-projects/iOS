//
//  PickUpRootView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.06.2022.
//

import SwiftUI
import MapKit
import SwiftyJSON


struct PickUpRootView: View {
    @StateObject var vm = PickUpRootVM()
    @EnvironmentObject var sessionManager: SessionManager
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
                
                RadiusSelectBtn()
                    .padding(.top, 24)
                    .onTapGesture {
                        vm.showRaduisPicker = true
                    }
                
                Text("Stores available: \(vm.availableStores.count)")
                    .textSecond()
                    .padding([.horizontal,.top], 24)
                    .hLeading()
                
                if vm.selectedTab == .list{
                    PickUpListView(rootVM: vm)
                        .transition(.fade)
                }else{
                    PickUpMapView(rootVM: vm)
                        .transition(.fade)
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
        .navBarSettings("Choose store")
        .onAppear{
            sessionManager.userData(withUpdate: true) { user in
                vm.userData = user
                vm.getStores(radius: vm.selectedRadius)
            }
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
