//
//  OrderReviewView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 13.03.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Amplitude

struct OrderReviewView: View {
    
    @ObservedObject var vm = OrderReviewVM()
    
    @State var data: OrderDetailsReview
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    @EnvironmentObject var orderNavigationManager: OrderNavigationManager

    var body: some View {
        
        ZStack{
            if orderNavigationManager.showOrderSuccessView{
                OrderSuccessView()
            }else{
                VStack{
                    
                    //main scroll
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        Text("List of items")
                            .textCustom(.coreSansC65Bold, 14, Color.col_text_second)
                            .padding(.top, 24)
                            .padding(.leading, 35)
                            .hLeading()
                        
                        //items view
                        VStack(spacing: 0){
                            if let productsInCart = cartManager.cartData?.cartDetails{
                                ForEach(productsInCart, id: \.self) { product in
                                    ProductCompactRow(data: OrderDetailModel(quanity: product.quantity, product: product.product))
                                    
                                    CustomDivider()
                                        .opacity(productsInCart.last != product ? 1 : 0)
                                    
                                }
                                .background(Color.col_bg_second.cornerRadius(12))
                                .padding(.horizontal, 24)
                            }
                        
                            
                            //Pricing view
                            CalculationPriceView(data: $data)
                                .padding(.top, 24)
                                .padding(.horizontal, 24)
                            
                            if let cartData = cartManager.cartData{
                                if cartData.discount > 0{
                                    Text("Your $\(cartData.discount.formattedString(format: .int)) discount is applied")
                                        .textCustom(.coreSansC45Regular, 16, Color.col_green_main)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(Color.col_green_second.cornerRadius(12))
                                        .padding(.top, 10)
                                        .padding(.horizontal, 24)
                                }
                            }
                            
                            
                            Text("Delivery details")
                                .textCustom(.coreSansC65Bold
                                            , 14, Color.col_text_second)
                                .padding(.top, 24)
                                .padding(.leading, 35)
                                .hLeading()
                            
                            //delivery user data
                            UserInfoView()
                        }
                        .padding(.top, 8)
                        
                        Text("Our courier will ask you to show your ID \nto verify your identity and age.")
                            .foregroundColor(ColorManager.Profile.lilacColor)
                            .padding(.top, 24)
                            .padding(.horizontal, 24)
                            .hLeading()
                        
                        RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, showIcon: false, title: "Place Order") {
                            vm.disableNavButton = true
                            print("tap button")
                            vm.confirmOrder(orderDetailsReview: data) { success in
                                if success {
                                    print("succsess")
                                    orderNavigationManager.showOrderSuccessView = true
                                    if UserDefaults.standard.bool(forKey: "EnableTracking"){

                                    Amplitude.instance().logEvent("make_order")
                                    }
                                } else {
                                    print("errrrorrr")
                                    vm.buttonState = .def
                                    vm.showAlert = true
                                    vm.disableNavButton = false
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top)
                    }
                }
                .alert(isPresented: self.$vm.showAlert, content: {
                    Alert(title: Text("Order creation failed"),
                          message: Text("Error"),
                          dismissButton: .default(Text("OK")))
                })
                .onAppear {
                    orderTrackerManager.disconnect()
                }
                .onDisappear {
                    orderTrackerManager.connect()
                }
            }
        }
        .navigationTitle(orderNavigationManager.showOrderSuccessView ? "" : "Order review")
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                ZStack{
                    Image("backNavBtn")
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                .onTapGesture {
                    if !vm.disableNavButton{
                        self.mode.wrappedValue.dismiss()
                    }
                }
                .opacity(orderNavigationManager.showOrderSuccessView ? 0 : 1)
            }
        })
    }
}
