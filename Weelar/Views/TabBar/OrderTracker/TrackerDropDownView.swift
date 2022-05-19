//
//  TrackerDropDownView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 22.04.2022.
//

import SwiftUI

struct TrackerDropDownView: View {
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
        
    @State var showMenu = false
    
    var body: some View {
        VStack{
            HStack(spacing: 0){
                Text("#\(orderTrackerManager.currentOrder?.number ?? "")")
                    .textCustom(.coreSansC65Bold, 14, orderTrackerManager.currentState?.color ?? Color.clear)
                    .padding(.leading, 12)
                    .padding(.trailing, 7)
                    .offset(y: 1)
                
                if orderTrackerManager.aviableOrders.count > 1{
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image("downArrow")
                                .rotationEffect(.radians(!showMenu ? .pi * 2 : .pi),
                                                anchor: .center)
                        )
                        .padding(.trailing, 6)
                }
            }
            .frame(height: 32)
            .background(Color.col_gray_dropdown_button.cornerRadius(24))
            .shadow(color: Color.col_black.opacity(showMenu ? 0.15 : 0), radius: 3, x: 0, y: 4)
            .onTapGesture {
                withAnimation(.spring()){
                    if orderTrackerManager.aviableOrders.count > 1{
                        showMenu.toggle()
                    }
                }
            }
            .hTrailing()
            
            if showMenu{
                VStack(spacing: 0){
                    ForEach(orderTrackerManager.aviableOrders){ order in
                        if order.id != orderTrackerManager.currentOrder?.id{
                            Text("#\(order.number)")
                                .textCustom(.coreSansC65Bold, 14, Color.col_text_white)
                                .padding(.leading, 12)
                                .padding(.vertical, 7)
                                .hLeading()
                                .onTapGesture {
                                    // set current view
                                    orderTrackerManager.currentOrder = order
                                    showMenu = false
                                }
                        }
                    }
                }
                
            }
        }
        .background(Color.col_gray_dropdown_bg
                        .opacity(showMenu ? 1 : 0)
                        .cornerRadius(radius: 12, corners: [.bottomLeft, .bottomRight])
                        .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
        )
        .hTrailing()
        .padding(.horizontal, 7)
    }
}


extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
