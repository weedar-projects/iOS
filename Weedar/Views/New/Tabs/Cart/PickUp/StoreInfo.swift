//
//  StoreInfo.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI

struct StoreInfo: View{
    
    @StateObject var rootVM: PickUpRootVM
    @EnvironmentObject var orderNavigationManager: OrderNavigationManager
    var body: some View{
        ZStack{
            if let store = rootVM.selectedStore {
                VStack{
                    
                    Spacer()
                    
                    ZStack{
                        Color.col_white.cornerRadius(radius: 12, corners: [.topLeft,.topRight])
                        
                        Button(action: {
                            withAnimation {
                                rootVM.showStoreInfo = false
                            }
                        }, label: {
                            Image("xmark")
                                .resizable()
                                .frame(width: 12, height: 12, alignment: .center)
                        })
                        .vTop()
                        .hTrailing()
                        .padding(19)
                        
                        VStack{
                            Text(store.address)
                                .textCustom(.coreSansC45Regular, 28, Color.col_text_main)
                                .hLeading()
                                .padding(24)
                                .padding(.top, 14)
                            
                            VStack(alignment: .leading, spacing: 0){
                                Row(icon: "calendar_icon", value: store.daysWork)
                                CustomDivider()
                                Row(icon: "clock_icon", value: store.timeWork, closed: store.close)
                                CustomDivider()
                                Row(icon: "phone_icon", value: format(phone: store.phone))
                            }
                            .background(
                                RadialGradient(colors: [Color.col_gradient_blue_second,
                                                        Color.col_gradient_blue_first],
                                               center: .center,
                                               startRadius: 0,
                                               endRadius: 220)
                                .opacity(0.25)
                                .clipShape(CustomCorner(corners: .allCorners,
                                                        radius: 12))
                            )
                            .padding(.horizontal, 24)
                            if store.close{
                            Text("The store is closed, but you can leave an order, \nwe will process it in the morning.")
                                .textSecond()
                                .padding(.top, 10)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            }
                            
                            Spacer()
                            ZStack{
                                RadialGradient(colors: [Color.col_gradient_blue_second,
                                                        Color.col_gradient_blue_first],
                                               center: .center,
                                               startRadius: 0,
                                               endRadius: 220)
                                .opacity(0.25)
                                .clipShape(CustomCorner(corners: .allCorners,
                                                        radius: 12))
                                .frame(height: 48)
                                
                                Text("Directions")
                                    .textCustom(.coreSansC55Medium, 16, Color.col_blue_main)
                            }
                            .padding([.horizontal,.bottom], 24)
                            .onTapGesture {
                                rootVM.showDirectionsView = true
                            }
                            
                            MainButton(title: "Review Order") {
                                rootVM.makeOrder { order in
                                    orderNavigationManager.currentCreatedOrder = rootVM.getCreatedOrder(order: order)
                                    orderNavigationManager.orderType = .pickup
                                    orderNavigationManager.showOrderReviewView = true
                                }
                            }
                            .padding([.bottom,.horizontal],24)
                            .padding(.bottom, 12)
                        }
                    }
                    .frame(height: store.close ? 545 : 512)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    @ViewBuilder
    func Row(icon: String, value: String, closed: Bool = false) -> some View {
        HStack(spacing: 0){
            Image(icon)
                .padding(.horizontal, 18)
            
            Text(value)
                .textDefault()
            Spacer()
            if closed{
                Text("Closed")
                    .textCustom(.coreSansC45Regular, 16, Color.col_pink_main)
                    .padding(.trailing, 18)
            }
        }
        .frame(height: 48)
    }
    
    func format(phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in "+X (XXX) XXX-XXXXXX" where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
}
