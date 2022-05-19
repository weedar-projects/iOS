//
//  OrderSuccessView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 14.03.2022.
//

import SwiftUI

struct OrderSuccessView: View {
    @Environment(\.rootPresentationMode) private var rootPresentationMode: Binding<RootPresentationMode>

    @EnvironmentObject var orderNavigationManager: OrderNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        ZStack{
            Color.col_green_main
                .edgesIgnoringSafeArea(.all)
            
            //imgage
            Image("splash-background-lines")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3, alignment: .top)
                .opacity(0.5)
                .edgesIgnoringSafeArea(.top)
                .vTop()
            
            VStack{
                //Logo
                Image("logo_new")
                    .resizable()
                    .frame(width: 117, height: 117)
                    .hLeading()
                    .padding(.top, getSafeArea().top)
                
                Text("Thanks \nfor your order!")
                    .hLeading()
                    .textCustom(.coreSansC65Bold, 40, Color.col_text_white)
                    .padding(.top, 24)
                
                Text("ordersuccessview.description".localized)
                    .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                    .hLeading()
                    .padding(.top, 8)
                
                
                Spacer()
                
                MainButton(title: "Back to store", action: {
                    orderNavigationManager.hideAll()
                    tabBarManager.currentTab = .catalog
                    tabBarManager.show()
                })
                    .padding(.bottom,tabBarManager.showOrderTracker && tabBarManager.isHidden == false ? 50 : 0)

            }
            .padding(.horizontal, 24)
            .onDisappear {
                cartManager.getCart()
            }
        }
        
    }
}
