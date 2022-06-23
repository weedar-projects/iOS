//
//  MyOrdersListView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 31.03.2022.
//

import SwiftUI
import Amplitude

struct MyOrdersListView: View {
    
    @StateObject var vm = MyOrdersListVM()
    
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        ZStack{
            VStack{
                
                OrderTypePicker()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack{
                        if !vm.orderSections.isEmpty{
                    ForEach(vm.orderSections) { section in
                        Text(section.date)
                            .textCustom(.coreSansC65Bold, 14, Color.col_text_second)
                            .padding(.leading,36)
                            .hLeading()
                            .padding(.top, 24)
                        ForEach(section.orders, id: \.id) { order in
                            NavigationLink {
                                MyOrderView(id: order.id)
                                    .navBarSettings("Order #\(order.number)")
                                    .onAppear{
                                        if UserDefaults.standard.bool(forKey: "EnableTracking"){
                                        Amplitude.instance().logEvent("select_order", withEventProperties: ["order_number" : order.number, "order_status" : order.state])
                                        }
                                    }
                            } label: {
                                ZStack{
                                    RadialGradient(colors: [Color.col_gradient_blue_second,
                                                            Color.col_gradient_blue_first],
                                                   center: .center,
                                                   startRadius: 0,
                                                   endRadius: 220)
                                    .clipShape(CustomCorner(corners: .allCorners, radius: 12))
                                    .opacity(0.25)
                                    
                                    HStack{
                                        VStack(alignment: .leading,spacing: 5){
                                            Text("$\(String(format: "%.2f",order.totalSum))")
                                                .textCustom(.coreSansC65Bold, 16, Color.col_black)
                                                
                                            Text("#\(order.number)")
                                                .textCustom(.coreSansC45Regular, 12, Color.col_text_second)
                                        }.offset(y: 2)
                                        
                                        Spacer()
                                        
                                        OrderStatusView(status: order.state, isPickup: order.partner.isPickUp)
                                        
                                        Image("arrowRight")
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .frame(height: 48)
                            }
                            .isDetailLink(false)
                       //     .padding(.top, 4)
                            .padding(.horizontal, 24)

                        }
                    }
                        }else{
                            EmptyOrderList()
                                .opacity(vm.loading ? 0 : 1)
                                .padding(.top, 170)
                        }
                    }
                    .padding(.bottom, tabBarManager.tabBarHeight)
                }
            }
        }
        .navBarSettings("My orders")
        .onAppear(){
            vm.getOrderList() {}
        }
    }
    
    @ViewBuilder
    func EmptyOrderList() -> some View {
        ZStack{
            RadialGradient(colors: [Color.col_gradient_blue_second,
                                    Color.col_gradient_blue_first],
                           center: .center,
                           startRadius: 0,
                           endRadius: 220)
            .clipShape(CustomCorner(corners: .allCorners, radius: 12))
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .padding(.horizontal, 53)
                
                .opacity(0.25)
            
            
            VStack{
                Image("emptyOrders_icon")
                
                Text("You don't have \nany orders yet.")
                    .textCustom(.coreSansC55Medium, 16, Color.col_text_main)
                    .padding(.top, 12)
            }
        }
    }
    
    @ViewBuilder
    func OrderTypePicker() -> some View {
        HStack(spacing: 0){
            Text("Delivery")
                .textCustom(.coreSansC65Bold, 16, vm.selectedTab == .delivery ? Color.col_text_white : Color.col_text_main)
                .frame(width: (getRect().width / 2 - 24), height: 44)
                .background(Color.col_white.opacity(0.01))
                .onTapGesture {
                    withAnimation {
                        vm.selectedTab = .delivery
                    }
                }
            
            Text("Pick Up")
                .textCustom(.coreSansC65Bold, 16, vm.selectedTab == .pickup ? Color.col_text_white : Color.col_text_main)
                .frame(width: (getRect().width / 2 - 24), height: 44)
                .background(Color.col_white.opacity(0.01))
                .onTapGesture {
                    withAnimation {
                        vm.selectedTab = .pickup
                    }
                    
                }
        }
        .frame(maxWidth: .infinity)
        .background(
            HStack{
                Color.col_black
                    .frame(width: (getRect().width / 2 - 24), height: 44)
                    .cornerRadius(radius: 12, corners: vm.selectedTab == .pickup ? [.bottomRight, .topRight] : [.bottomLeft, .topLeft])
                    .animation(.interactiveSpring(response: 0.15,
                                                  dampingFraction: 0.65,
                                                  blendDuration: 1.5),
                               value: vm.selectedTab == .pickup)
                    .offset(x: vm.selectedTab == .pickup ? (getRect().width / 2 - 24) : 0)
                    .hLeading()
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder()
                .foregroundColor(Color.col_borders)
            
        )
        .padding(.horizontal, 24)
    }
}

struct MyOrdersListView_Previews: PreviewProvider {
    static var previews: some View {
        MyOrdersListView()
    }
}

