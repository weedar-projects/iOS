//
//  StoreInfo.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI

struct StoreInfo: View{
    
    @StateObject var rootVM: PickUpRootVM
    
    var body: some View{
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
                        
                        VStack(alignment: .leading, spacing: 0){
                            Row(icon: "calendar_icon", value: "Monday - Sunday")
                            CustomDivider()
                            Row(icon: "clock_icon", value: "10AM - 8PM")
                            CustomDivider()
                            Row(icon: "phone_icon", value: format(phone: "3414231231"))
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
                        .onTapGesture {
                            
                        }
                        .padding(24)
                        
                        MainButton(title: "Done") {
                            
                        }
                        .padding([.bottom,.horizontal],24)
                    }
                }
                .frame(height: 458)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    @ViewBuilder
    func Row(icon: String, value: String) -> some View {
        HStack(spacing: 0){
            Image(icon)
                .padding(.horizontal, 18)
            
            Text(value)
                .textDefault()
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
