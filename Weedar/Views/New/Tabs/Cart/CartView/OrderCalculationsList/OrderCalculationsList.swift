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
            Text("Order details")
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
                    .padding(.horizontal, 15)
                    
                    CustomDivider()
                        
                HStack{
                    Text("Product price")
                        .textDefault(size: 16)
                    Spacer()
                    
                    Text("$\(cartData.productsSum.formattedString(format: .percent))")
                        .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                }
                .frame(height: rowHeingt)
                .padding(.horizontal, 15)
                
                if cartData.discount.value > 0{
                    CustomDivider()
                    
                    HStack{
                        Text(cartData.discount.type == .firstOrder ? "First order discount" : "Promo code discount")
                            .textCustom(.coreSansC45Regular, 16, Color.col_green_main)
                        Spacer()
                        
                        Text("-\(cartData.discount.measure == .dollar ? "$" : "%")\(cartData.discount.value.formattedString(format: .percent))")
                            .textCustom(.coreSansC65Bold, 16, Color.col_green_main)
                    }
                    .frame(height: rowHeingt)
                    .padding(.horizontal, 15)
                }
                
                CustomDivider()
                
                    HStack{
                        Text("Subtotal")
                            .textDefault(size: 16)
                        Spacer()
                        
                        Text("$\(cartData.sum.formattedString(format: .percent))")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    }
                    .frame(height: rowHeingt)
                    .padding(.horizontal, 15)
                
            }   
            .background(
                RadialGradient(colors: [Color.col_gradient_blue_second,
                                        Color.col_gradient_blue_first],
                               center: .center,
                               startRadius: 0,
                               endRadius: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .opacity(0.25)
            )
            
            if !cartData.priceCorresponds{
                //Minimum price info
                Text("Minimum order amount is $50.")
                    .hLeading()
                    .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
            }
            
            
            HStack{
                Text("Delivery fee")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                
                Spacer()
                
                Text("$\(cartData.deliverySum.formattedString(format: .percent))")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
            }
            .padding(.horizontal, 15)
            .background(
                RadialGradient(colors: [Color.col_gradient_blue_second,
                                                Color.col_gradient_blue_first],
                                       center: .center,
                                       startRadius: 0,
                                       endRadius: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(0.25)
                .frame(height: rowHeingt)
            )
            .frame(height: rowHeingt)
            .padding(.top, 19)
            
            HStack{
                Text("Total")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                
                Spacer()
                
                Text("$\(cartData.totalSum.formattedString(format: .percent))")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
            }
            .padding(.horizontal, 15)
            .background(
                RadialGradient(colors: [Color.col_gradient_blue_second,
                                                Color.col_gradient_blue_first],
                                       center: .center,
                                       startRadius: 0,
                                       endRadius: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(0.25)
                .frame(height: rowHeingt)
            )
            .padding(.top, 19)
        }
        }
    }
}
