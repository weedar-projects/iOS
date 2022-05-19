//
//  OrderTrackerStatusTopView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI

struct OrderTrackerStatusTopView: View {
    
    @Binding var currentState: OrderTrackerStateModel?
    
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
                                .fill(currentState.id >= state.id ? state.color : Color.clear)
                                .frame(width: (getRect().width - 72)  / 4, height: 4)
                           
                            ShimmerView()
                                .opacity(currentState.id == state.id ? 0.8 : 0)
                                .clipShape(Capsule())
                                .frame(width: (getRect().width - 72)  / 4, height: 4)
                            
                        }
                    }
                }
                
                ZStack{
                    currentState.color
                        .cornerRadius(24)
                    
                    Text(currentState.state.rawValue)
                        .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .padding(.top)
            }
        }
    }
}
