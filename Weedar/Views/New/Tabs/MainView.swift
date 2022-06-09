//
//  MainView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 26.04.2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    
    init(){
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack{
        TabView(selection: $tabBarManager.currentTab) {
            ForEach(tabBarManager.tabBarPages) { item in
                AnyView(_fromValue: item.page)
                    .tabItem {
                        Color.clear
                    }
                    .tag(item.tag)
            }
        }
        .overlay(
            ZStack{
                ZStack{
                    Color.col_white
                        .opacity(0.9)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            NotificationCenter.default.post(name: .closeOrderTrackerView, object: nil)
                        }
                }
                .opacity(tabBarManager.showOrderTracker ? tabBarManager.detailScrollValue : 0)
                

                VStack(spacing: 0){
                    
                    OrderTrackerView(detailScrollValue: $tabBarManager.detailScrollValue)
                        .offset(y: tabBarManager.showOrderTracker ? 0 : tabBarManager.tabBarHeight + getSafeArea().bottom + 50)
                        .opacity(tabBarManager.showOrderTracker ? 1 : 0)
                    
                    if tabBarManager.showOrderTracker{
                        Rectangle()
                            .fill(Color.col_white.opacity(tabBarManager.showOrderDetailView ? 0.2 : 0))
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                    }
                    
                    CustomTabBarView()
                    
                }
//                .opacity(tabBarManager.showARView ? 0 : 1)
                .offset(y: tabBarManager.isHidden ? tabBarManager.tabBarHeight + getSafeArea().bottom + 135 : 0)
            }
            , alignment: .bottom)
        .edgesIgnoringSafeArea(.bottom)
        }
    }
}
