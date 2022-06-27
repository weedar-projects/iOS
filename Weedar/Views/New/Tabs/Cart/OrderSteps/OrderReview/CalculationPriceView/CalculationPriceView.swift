//
//  CalculationPriceView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 14.03.2022.
//

import SwiftUI

struct CalculationPriceView: View {
    
    @EnvironmentObject var cartManager: CartManager
    
    @Binding var data: OrderDetailsReview
    
    @State var showDelivery: Bool = true
    
    @State var lightText = false
    
    @State private var showCalculations = false
    
    @State var showDiscount = false
    
    var body: some View{
        VStack(spacing: 0){
            HStack{
                VStack{
                    Text("Total")
                        .textCustom(.coreSansC65Bold, 16, lightText ? Color.col_text_white : Color.col_text_main)
                        .hLeading()
                    
                    Text("\(data.totalWeight ?? "")g")
                        .textCustom(.coreSansC45Regular, 12, lightText ? Color.col_text_white.opacity(0.7) : Color.col_text_second)

                        .hLeading()
                        .padding(.top, 1)
                }
                .padding([.top, .bottom, .leading], 16)
                
                Spacer()
                
                VStack{
                    Text("$\(data.totalSum.formattedString(format: .percent))")
                        .textCustom(.coreSansC65Bold, 16, lightText ? Color.col_text_white : Color.col_text_main)
                        .hTrailing()
                    
                    Text("Tax included")
                        .textCustom(.coreSansC45Regular, 12, lightText ? Color.col_text_white.opacity(0.7) : Color.col_text_second)
                        .hTrailing()
                        .padding(.top, 1)
                }
                
                
                    if lightText{
                        Image("arrow-top")
                            .colorInvert()
                            .rotationEffect(.radians(showCalculations ? .pi * 2 : .pi),
                                            anchor: .center)
                            .padding(.trailing, 16)
                    } else{
                        Image("arrow-top")
                            .rotationEffect(.radians(showCalculations ? .pi * 2 : .pi),
                                            anchor: .center)
                            .padding(.trailing, 16)
                    }
                
            }
            .background(
                lightText ? nil :
                RadialGradient(colors: [Color.col_gradient_blue_second,
                                        Color.col_gradient_blue_first],
                               center: .center,
                               startRadius: 0,
                               endRadius: 220)
                .clipShape(CustomCorner(corners: showCalculations ? [.topRight, .topLeft] : .allCorners, radius: 12))
                .opacity(0.25)
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    showCalculations.toggle()
                }
            }
            
            CustomDivider()
                .opacity(showCalculations ? 1 : 0)
            
            if showCalculations{
                VStack(spacing: 13){
                    
                    CalculationRow(title: "Product price",
                                   value:  $data.sum,
                                   lightText: lightText)
                    if showDelivery{
                        CalculationRow(title: "Delivery fee",
                                       value: Binding<Double>.constant(10),
                                       lightText: lightText)
                    }
                    CalculationRow(title: "Excise tax",
                                   value: $data.exciseTaxSum,
                                   lightText: lightText)
                    
                    CalculationRow(title: "Sale tax",
                                   value: $data.salesTaxSum,
                                   lightText: lightText)
                    
                    CalculationRow(title: "Local tax",
                                   value: $data.localTaxSum,
                                   lightText: lightText )
                    
                    if let discount = data.discount, discount.value > 0{
                        HStack{
                            Text(discount.type == .firstOrder ? "First order discount" : "Promo code discount")
                                .textCustom(.coreSansC45Regular, 16, lightText ? Color.col_text_white : Color.col_green_main)
                            
                            Spacer()
                            
                            Text("-\(discount.measure == .dollar ? "$" : "%")\(discount.value.formattedString(format: .percent))")
                                .textCustom(.coreSansC45Regular, 16, lightText ? Color.col_text_white : Color.col_green_main)
                        }
                    }
                }
                .padding(15)
                .background(
                    lightText ? nil :
                    RadialGradient(colors: [Color.col_gradient_blue_second,
                                            Color.col_gradient_blue_first],
                                   center: .center,
                                   startRadius: 0,
                                   endRadius: 220)
                    .clipShape(CustomCorner(corners: [.bottomLeft, .bottomRight], radius: 12))                    .opacity(0.25)
                )
            }
        }
        .onAppear {
            print(data)
        }
    }
}
