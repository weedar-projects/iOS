//
//  CustomTabBarView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 16.03.2022.
//

import SwiftUI
 

struct CustomTabBarView: View {

    @EnvironmentObject var tabBarManager: TabBarManager

    var body: some View {
            HStack{
                ForEach(tabBarManager.tabBarPages) { page in
                    CustomTabBarButtonView(page: page, selected: $tabBarManager.currentTab)
                }
            }
            .padding(.horizontal,20)
            .padding(.top, 12)
            .frame(height: tabBarManager.tabBarHeight, alignment: .top)
            .background(Color.col_black)
            .cornerRadius(radius: 24, corners: [.topRight, .topLeft])
    }
}

let isSmallDevise = UIScreen.main.bounds.height <  812

struct CustomTabBarButtonView: View {
    @State var page: TabBarPageModel
    @Binding var selected : TabBarPages
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var orderTrackingManager: OrderTrackerManager
    @State var tapCount = 0
    var body: some View{
        ZStack{
            HStack(spacing: 7){
                Image(page.icon)
                    .resizable()
                    .frame(width: selected == page.tag ? 18 : 25, height: selected == page.tag ? 18 : 25, alignment: .leading)
                 //.font(.body)
                     .foregroundColor(selected == page.tag ? Color.black : Color.col_white.opacity(0.5))
                     .overlay(
                        badge(cartManager.productsCount, display: page.tag == .cart && selected != .cart)
                            .offset(x: 20)
                        , alignment: .trailing)
                if selected == page.tag{
                    Text(page.title)
                        .textCustom(.coreSansC65Bold, 15, selected == page.tag ? Color.col_black : Color.clear)
                }
            }
            .frame(width: (UIScreen.main.bounds.width - 50)/3)
            .padding(.vertical,10)
            .background(
                selected == page.tag ?
                Image.bg_gradient_main
                    .resizable()
                    .cornerRadius(12) : nil
            )
//            .background(selected == page.tag ? Color.col_yellow_main : Color.clear)
            .overlay(
                badge(cartManager.productsCount, display: page.tag == .cart && selected == .cart)
               , alignment: .topTrailing)
        }
        .onTapGesture {
            AnalyticsManager.instance.event(key: .select_bar_menu,properties:  [.tab_select_catalog : page.title])
            withAnimation(.default){
                if page.tag == selected {
                    tabBarManager.refreshNav(tag: selected)
                }
                selected = page.tag
                NotificationCenter.default.post(name: .closeOrderTrackerView, object: nil)
            }
        }
    }
        
    @ViewBuilder
    func badge(_ productsInCart: Int, display: Bool = false) -> some View {
        if productsInCart > 0 && display {
            ZStack{
                Color.col_pink_main.frame(width: 20, height: 20).clipShape(Circle())

            Text("\(productsInCart)")
                .textCustom(.coreSansC65Bold, 12, Color.col_text_white)
                .padding(2)
                .offset(y: 1)
            }
            .offset(x: selected == .cart ? 7 : 4, y: selected == .cart ? -7 : 0)
        } else {
            Color.clear
        }
    }
}

struct TabBarPageModel: Identifiable {
    var id = UUID()
    var page: Any
    var icon: String
    var title: String
    var tag: TabBarPages
}
