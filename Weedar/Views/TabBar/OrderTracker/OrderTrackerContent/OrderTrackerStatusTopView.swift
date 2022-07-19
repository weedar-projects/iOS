//
//  OrderTrackerStatusTopView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI

struct OrderTrackerStatusTopView: View {
    
    @Binding var currentState: OrderTrackerStateModel?
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    @State var allState: [OrderTrackerStateModel] = []
    
    var body: some View{
        if let currentState = currentState {
            VStack{
                HStack(spacing: 8){
                    ForEach(allState, id: \.self) { state in
                        ZStack{
                            Capsule()
                                .fill(Color.col_white.opacity(0.2))
                                .frame(width: (getRect().width - 72)  / 4, height: 4)
                            
                            Capsule()
                                .fill(currentState.id >= state.id ? state.colors.first! : Color.clear)
                                .frame(width: (getRect().width - 72)  / 4, height: 4)
                           
                            ShimmerView()
                                .opacity(currentState.id == state.id ? 0.8 : 0)
                                .clipShape(Capsule())
                                .frame(width: (getRect().width - 72)  / 4, height: 4)
                            
                        }
                    }
                }
                
                ZStack{
                    currentState.colors.first
                    
                    Capsule()
                        .fill(currentState.colors.last!)
                        .blur(radius: 24)
                        .scaleEffect(CGSize(width: 0.75, height: 0.4))
                    if let currentOrder = orderTrackerManager.currentOrder{
                        Text(currentOrder.orderType == .delivery ? currentState.deliveryState.rawValue : currentState.id == 2 ? "Available for Pick up" : currentState.pickupState.rawValue)
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .cornerRadius(24)
                .padding(.top)
            }
        }
    }
}
