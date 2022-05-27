//
//  CartView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI
import Amplitude
import SDWebImageSwiftUI

struct CartView: View {
    @State private var showAlert = false

    @StateObject var vm: CartVM
    
    @StateObject var cartRootVM: CartRootVM
    
    @EnvironmentObject var cartManager: CartManager
    
    @EnvironmentObject var tabBarManager: TabBarManager
    
    @EnvironmentObject var orderNavigationManager: OrderNavigationManager
    
    @ObservedObject var vmDelivery = OrderDeliveryVM()
    
    var body: some View {
        ZStack{
            
            NavigationLink(isActive: $orderNavigationManager.showDeliveryView) {
                OrderDeliveryView(vm: vmDelivery)
            } label: {
                Color.clear
            }.isDetailLink(false)

            Color.white
            
            VStack{
                
                ScrollView(.vertical, showsIndicators: false) {
                    //description
                    Text("Only cash is accepted as a payment method")
                        .textSecond()
                        .hLeading()
                        .padding(.top, 3)
                        .padding(.horizontal, 24)
                    //product list view
                    if let productsInCart = cartManager.cartData?.cartDetails{
                        ForEach(productsInCart, id: \.self) { product in
                                ProductCartRowView(item: product.product,
                                                   quantityField: String(product.quantity))
                                    .padding(.horizontal, 24)
                                    .padding(.top, 24)
                            }
                    }
                    
                  DiscountView()
                    //Prices
                        OrderCalculationsList()
                            .padding(.top, 24)
                            .padding(.horizontal, 24)
                    
                    if let data = cartManager.cartData, data.totalSum < 50{
                        //Minimum price info
                        Text("Minimum order amount is $50.")
                            .hLeading()
                            .textSecond()
                            .padding([.horizontal, .top], 24)
                    }
                    
                    //create order button
                    
                    if let cartData = cartManager.cartData{
                    MainButton(title: "Proceed to checkout") {
                        orderNavigationManager.showDeliveryView = true
                        tabBarManager.hide()
                        if let productsInCart = cartManager.cartData?.cartDetails{
                            for product in productsInCart {
                                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                                    Amplitude.instance().logEvent("proceed_checkout", withEventProperties: ["category" : product.product.type,
                                                                                                            "product_id" : product.product.id,
                                                                                                            "product_price" : product.product.price.formattedString(format: .percent)])
                                }
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    .padding(.bottom, tabBarManager.showOrderTracker ? 95 : isSmallIPhone() ? 35 : 25)
                    .opacity(cartData.priceCorresponds ? 1 : 0.5)
                    .disabled(!cartData.priceCorresponds)
                    }
                    Spacer()
                }
                
            }
            
        }
        .navBarSettings("Cart", backBtnIsHidden: true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ZStack{
                    Text("Clear cart")
                        .foregroundColor(Color.col_pink_main)
                }.onTapGesture {
                    showAlert = true
                }
                .customDefaultAlert(title: "Clear cart", message: "All items will be removed. Are you sure you want to clear the Cart?", isPresented: $showAlert,
                                    firstBtn: .default(Text("Cancel")),
                                    secondBtn: .destructive(
                                        Text("Clear"),
                                        action: {
                                            self.cartManager.clearAllProductCart()
                                        }
                                    ))
            }
        }
        .sheet(isPresented: $vm.showDiscontCodeView, content: {
            DiscontCodeView(showView: $vm.showDiscontCodeView)
        })
//        .onAppear() {
//            cartManager.updateCalculations()
//            vm.validateToNext(concentrated: cartManager.totalConcentrated,
//                              nonConcentrated: cartManager.totalNonConcentrated,
//                              sum: cartManager.totalPrice())
//            vm.validateSum(sum: cartManager.totalPrice())
//
//            cartManager.checkDiscount()
//        }
    }
    
    
    @ViewBuilder
    func DiscountView() -> some View {
        ZStack{
            ZStack{
                Color.col_gradient_green_first
                
                Capsule()
                    .fill(Color.col_white)
                    .blur(radius: 23)
                    .scaleEffect(1.2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            
            if let discount = cartManager.cartData?.discount, discount.value > 0{
                if discount.type == .firstOrder{
                    Text("Your $\(discount.value.formattedString(format: .int)) discount is applied")
                        .textCustom(.coreSansC45Regular, 16, Color.col_green_main)
                        .offset(y: 2)
                }
                HStack{
                    Text("Promo code applied")
                        .textCustom(.coreSansC45Regular, 16, Color.col_green_main)
                        .offset(y: 2)
                    
                    Spacer()
                    
                    Image("checkmark")
                        .colorInvert()
                        .colorMultiply(Color.col_green_main)
                        .scaleEffect(0.5)
                }
                .padding(.horizontal, 18)
            }else{
                HStack{
                    Image.ticket_discount
                        .colorMultiply(Color.col_green_main)
                    
                    Text("Enter a promo code")
                        .textCustom(.coreSansC65Bold, 16, Color.col_green_main)
                }
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 24)
        .padding(.top, 34)
        .onTapGesture {
            vm.showDiscontCodeView = true
        }

    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartRootView()
    }
}



