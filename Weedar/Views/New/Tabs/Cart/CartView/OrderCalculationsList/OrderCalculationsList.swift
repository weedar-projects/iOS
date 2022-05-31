//
//  OrderCalculationsList.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI

struct OrderCalculationsList: View {
    
    @EnvironmentObject var cartManager: CartManager
    
    private let rowHeingt: CGFloat = 48
    
    var body: some View{
        if let cartData = cartManager.cartData{
        VStack{
            Text("Order Details")
                .textCustom(.coreSansC65Bold, 14, Color.col_text_second)
                .hLeading()
                .padding(.leading, 12)
            
            VStack(spacing: 0){
                
                    HStack{
                        Text("Total weight")
                            .textDefault(size: 16)
                        Spacer()
                        
                        Text("\(cartData.totalWeight.formattedString(format: .gramm))g")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    }
                    .frame(height: rowHeingt)
                    
                    CustomDivider()
                        
                    HStack{
                        Text("Subtotal")
                            .textDefault(size: 16)
                        Spacer()
                        
                        Text("$\(cartData.sum.formattedString(format: .percent))")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    }
                    .frame(height: rowHeingt)
                    
                    CustomDivider()
                        
                    HStack{
                        Text("Delivery fee")
                            .textDefault(size: 16)
                        Spacer()
                        
                        Text("$\(cartData.deliverySum.formattedString(format: .percent))")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    }
                    .frame(height: rowHeingt)
            }
            .padding(.horizontal, 15)
            .background(Color.col_bg_second.cornerRadius(12))
            
            if cartData.discount > 0{
                Text("Your $\(cartData.discount.formattedString(format: .int)) discount is applied")
                .textCustom(.coreSansC45Regular, 16, Color.col_green_main)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.col_green_second.cornerRadius(12))
            }

            HStack{
                Text("Total")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                
                Spacer()
                
                
                Text("$\(cartData.totalSum.formattedString(format: .percent))")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                
            }
            .padding(.horizontal, 15)
            .background(Color.col_bg_second.cornerRadius(12).frame(height: rowHeingt))
            .padding(.top, 19)
        }
        }
    }
}
