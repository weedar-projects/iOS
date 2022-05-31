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
                ZStack{
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
                            VStack{
                                if let productsInCart = cartManager.cartData?.cartDetails{
                                    ForEach(productsInCart, id: \.self) { product in
                                        ProductCompactRow(data: OrderDetailModel(quanity: product.quantity, product: product.product))
                                        
                                        CustomDivider()
                                            .opacity(productsInCart.last != product ? 1 : 0)
                                        
                                    }
                                    
                                }
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
                            .padding(.horizontal, 24)
                        
                            
                            //Pricing view
                            CalculationPriceView(data: $data)
                                .padding(.top, 24)
                                .padding(.horizontal, 24)
                            
                            
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
                    }
                }
                    RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, showIcon: false, title: "Make order") {
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
                    .background(Color.col_white)
                    .vBottom()
                    
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
