//
//  EmptyCartView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI


struct EmptyCartView: View {
    
    @StateObject var vm: EmptyCartVM
    
    @EnvironmentObject var tabBarManager: TabBarManager

    var body: some View{
        ZStack{
            Image("Background_Logo")
                .hTrailing()
            
            VStack{
                
                
                Text("It's nothing here yet.")
                    .textSecond()
                    .hLeading()
                    .padding(.top, 16)
                
                Spacer()
                
                MainButton(title: "Go to catalog") {
                    tabBarManager.currentTab = .catalog
                }
                .padding(.bottom, 80)
                .padding(.bottom, tabBarManager.showOrderTracker ? 95 : 0)
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Cart")
        
    }
}

struct EmptyCartView_Previews: PreviewProvider {
    static var previews: some View {
        CartRootView()
    }
}
