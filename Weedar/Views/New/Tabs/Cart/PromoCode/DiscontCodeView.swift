//
//  DiscontCodeView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 27.05.2022.
//

import SwiftUI

struct DiscontCodeView: View {
    
    @StateObject var vm = DiscontCodeVM()
    @EnvironmentObject var cartManager: CartManager
    
    @Binding var showView: Bool
    
    var body: some View {
        VStack{
            Button(action: {
                withAnimation {
                    self.showView = false
                }
            }, label: {
                Image("xmark")
                    .resizable()
                    .frame(width: 12, height: 12, alignment: .center)
            })
            .hTrailing()
            .padding(19)
            
            Text("Promo code")
                .textTitle()
                .hLeading()
                .padding([.horizontal, .top], 24)
            
            Image.ticket_discount_percent
                .resizable()
                .frame(width: 69, height: 48)
                .padding(.top, 24)
                .padding(.leading, 24)
                .hLeading()
            
            Text("Enter a promo code. You can use one discount at the time.")
                .textSecond()
                .padding([.horizontal,.top], 24)
            
            CustomTextField(text: $vm.code,
                            state: $vm.codeTFState, title: "",
                            placeholder: "Enter promo code here")
            .padding(.top,12)
            
            
            Text(vm.errorMessage)
                .textCustom(.coreSansC45Regular, 12, Color.col_pink_main)
                .padding(.horizontal, 24)
                .padding(.top, 6)
                .hLeading()
            
            Spacer()
            
            RequestButton(state: $vm.buttonState, isDisabled: $vm.btnDisabled,showIcon: false,title: "Apply") {
                vm.applyDiscount { cartData in
                    cartManager.cartData = cartData
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showView = false
                    }
                }
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 24)
        }
        
    }
}
