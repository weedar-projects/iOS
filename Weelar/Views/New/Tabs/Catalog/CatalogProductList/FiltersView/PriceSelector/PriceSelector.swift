//
//  PriceSelector.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 05.04.2022.
//

import SwiftUI

struct PriceSelector: View {
    
    @Binding var priceFrom: CGFloat
    @Binding var priceTo: CGFloat
    
    var body: some View{
        
        VStack(spacing: 0){
            //title
            Text("Price")
                .textCustom(.coreSansC45Regular, 14, Color.col_text_main)
                .hLeading()
                .padding(.leading, 36)
            
            // Price view
                HStack(spacing: 0){
                    //Price From Text
                    HStack{
                        Text("From")
                            .textCustom(.coreSansC45Regular, 16, Color.col_text_second.opacity(0.7))
                            .padding(.leading, 14)
                        
                        Text("$\(priceFormat(priceFrom))")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                            .padding(.leading, 8)
                    }
                    
                    //Price To Text
                    HStack{
                        Text("To")
                            .textCustom(.coreSansC45Regular, 16, Color.col_text_second.opacity(0.7))
                            .padding(.leading, 14)
                        
                        Text("$\(priceFormat(priceTo))")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                            .padding(.leading, 8)
                    }.hCenter()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.col_borders, lineWidth: 2)
                        .frame(height: 48)
                )
                .frame(height: 48)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            //Slider
            PriceSlider(priceFrom: $priceFrom, priceTo: $priceTo)
                .padding(.horizontal, 36)
                .offset(y: -8)
                
        }
    }
    
    func priceFormat(_ value: CGFloat) -> String {
        return String(format: "%.f", value)
    }
}
