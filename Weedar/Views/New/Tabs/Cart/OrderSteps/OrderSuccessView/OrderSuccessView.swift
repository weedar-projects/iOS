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
            Image("orderSuccessGradient")
                .resizable()
                .frame(width: getRect().width, height: getRect().height - getSafeArea().bottom)
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            //imgage
            VStack{
                //Logo
                Image("orderSuccessLogo")
                    .resizable()
                    .frame(width: 270, height: 70)
                    .hLeading()
                    .padding(.top, getSafeArea().top)
                
                Text("Thanks \nfor your order!")
                    .hLeading()
                    .textCustom(.coreSansC65Bold, 40, Color.col_text_main)
                    .padding(.top, 24)
                
                Text("ordersuccessview.description".localized)
                    .textCustom(.coreSansC45Regular, 16, Color.col_text_main)
                    .hLeading()
                    .padding(.top, 8)
                
                
                Spacer()
                
            }
            .padding(.horizontal, 24)
            .padding(.top, getSafeArea().top)
            
            VStack{
                HStack{
                    Text("Back to Store")
                        .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Image.bg_gradient_main)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .onTapGesture {
                    orderNavigationManager.hideAll()
                    tabBarManager.currentTab = .catalog
                    tabBarManager.show()
                }
                .padding(.bottom, 20)
                
            }
            .frame(height: getSafeArea().bottom + 90)
            .background(Color.col_black.cornerRadius(radius: 16, corners: [.topLeft,.topRight]))
            .padding(.bottom, 18)
            .padding(.bottom, isSmallIPhone() ? 35 : 0)
            .vBottom()
        }
        .edgesIgnoringSafeArea(.bottom)
        .onDisappear {
            cartManager.getCart()
        }
        
    }
}
