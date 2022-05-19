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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack{
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
                                    Color.col_borders.cornerRadius(12)
                                    HStack{
                                        VStack(alignment: .leading,spacing: 5){
                                            Text("$\(String(format: "%.2f",order.totalSum))")
                                                .textCustom(.coreSansC65Bold, 16, Color.col_black)
                                                
                                            Text("#\(order.number)")
                                                .textCustom(.coreSansC45Regular, 12, Color.col_text_second)
                                        }.offset(y: 2)
                                        
                                        Spacer()
                                        
                                        OrderStatusView(status: order.state)
                                        
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
                    }
                    .padding(.bottom, tabBarManager.tabBarHeight)
                }
            }
        }
        .navBarSettings("My orders")
        .onAppear(){
            vm.getOrderList {}
        }
    }
}

struct MyOrdersListView_Previews: PreviewProvider {
    static var previews: some View {
        MyOrdersListView()
    }
}

