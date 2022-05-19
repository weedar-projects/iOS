//
//  PriceSlider.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 05.04.2022.
//

import SwiftUI

struct PriceSlider: View {
    
    @Binding var priceFrom: CGFloat
    @Binding var priceTo: CGFloat
    
    private let maxWidth: CGFloat = UIScreen.main.bounds.width - 72 - 40
   
    var body: some View{
        
        ZStack(alignment: .leading){
            Rectangle()
                .fill(Color.clear)
                .frame(height: 2)

            Rectangle()
                .fill(
                    Color.col_purple_main
                )
                .frame(width: priceTo - priceFrom, height: 2)
                .offset(x: priceFrom + 20)
            
            HStack(spacing: 0) {
                Circle()
                    .fill(
                        Color.col_purple_main
                    )
                    .frame(width: 20, height: 20)
                    .offset(x: priceFrom)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                if value.location.x >= 0 && value.location.x <= priceTo {
                                    priceFrom = value.location.x
                                }
                            })
                    )
                
                Circle()
                    .fill(
                        Color.col_purple_main
                    )
                    .frame(width: 20, height: 20)
                    .offset(x: priceTo)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                if value.location.x >= priceFrom && value.location.x <= maxWidth {
                                    priceTo = value.location.x
                                }
                            })
                    )
            }
        }
        .onAppear {
            priceFrom = CGFloat(priceFrom)
            priceTo = CGFloat(priceTo)
        }
    }
}
