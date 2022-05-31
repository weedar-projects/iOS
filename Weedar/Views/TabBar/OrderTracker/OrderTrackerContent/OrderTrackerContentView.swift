//
//  OrderTrackerContentView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Amplitude

struct OrderTrackerContentView: View {
    
    @StateObject var vm = OrderTrackerContentVM()
    
    @Binding var detailScrollValue: CGFloat
    @Binding var disableScroll: Bool
    
    @Binding var openOrder: Bool
    
    @EnvironmentObject var tabBarManager: TabBarManager
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    
    var body: some View{
        ZStack{
            VStack{
                ZStack{
                    Text("Current order")
                        .textCustom(.coreSansC65Bold,20, Color.col_text_white)
                        .overlay(Color.col_black.opacity(detailScrollValue))
                        .hLeading()
                    
                    
                    Text("Order status")
                        .textCustom(.coreSansC65Bold,28 , Color.col_text_white)
                        .hLeading()
                        .opacity(detailScrollValue)
                        .padding(.top, openOrder ? 13 : 0)
                }
                .hLeading()

                    OrderTrackerStatusTopView(currentState: $orderTrackerManager.currentState,
                                              allState: vm.allState)
                        .padding(.top, 9)
                
                Text(orderTrackerManager.currentState?.deliveryText ?? "")
                    .textCustom(.coreSansC45Regular, 14, Color.col_white.opacity(0.8))
                    .foregroundColor(orderTrackerManager.currentState?.colors.first ?? Color.clear)
                    .padding(.top, 12)
                    .hLeading()
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack{
                        Text("List of items")
                            .textCustom(.coreSansC65Bold, 14, Color.col_text_white.opacity(0.7))
                            .padding(.leading, 11)
                            .padding(.top,12)
                            .hLeading()
                        if let products = orderTrackerManager.currentOrder?.orderDetails{
                        VStack{
                            ForEach(products) { product in
                                OrderProductCompactRow(data: product, lightText: true)
                                
                                CustomDivider()
//                                    .opacity(products.last().id == product.id ? 0 : 1)
                                
                            }
                        }
                        .background(Color.col_white.opacity(0.1).cornerRadius(12))
                        .padding(.top,8)
                        }
                        //Pricing view
                        
                        CalculationOrderPriceView()
                            .background(Color.col_white.opacity(0.1).cornerRadius(12))
                            .padding(.top, 12)
                        
                        Text("Delivery details")
                            .textCustom(.coreSansC65Bold, 14, Color.col_text_white.opacity(0.7))
                            .padding(.top, 12)
                            .padding(.leading, 11)
                            .hLeading()
                        
                        //delivery user data
                        VStack(alignment: .leading,spacing: 10){
                            Text("\(orderTrackerManager.currentOrder?.name ?? "")")
                                .textCustom(.coreSansC45Regular, 14, Color.col_text_white)
                            
                            Text("\(orderTrackerManager.currentOrder?.addressLine1 ?? "")")
                                .textCustom(.coreSansC45Regular, 14, Color.col_text_white)
                            
                            Text("\(orderTrackerManager.currentOrder?.phone ?? "")")
                                .textCustom(.coreSansC45Regular, 14, Color.col_text_white)
                        }
                        .hLeading()
                        .padding()
                        .background(Color.col_white.opacity(0.1).cornerRadius(12))
                        .padding(.top,8)
                        
                        if  orderTrackerManager.currentOrder?.state ?? 0 !=  7{
                            ZStack{
                                ZStack{
                                    Text("Cancel order")
                                        .textCustom(.coreSansC65Bold, 16, Color.col_pink_main)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .padding(.horizontal, 24)
                                .background(ButtonBGDarkGradient())
                                
                            }
                                .padding(.top, 12)
                                .onTapGesture {
                                    vm.showCancelAlert.toggle()
                                }
                            
                        }
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 23, height: 1)
                        .padding(.bottom, 200)
                        
                    }
                }
                .disabled(disableScroll)
                .padding(.top, 7)
            }
            
            StateAndDropDounView()
                .vTop()
                .hTrailing()
            
            if vm.loading{
                ZStack{
                    Color.col_black
                        .opacity(0.6)
                    LoadingAnimateView()
                }
            }
        }
        .onTapGesture(count: 2, perform: {
            tabBarManager.showOrderDetailView = true
        })
        .onChange(of: orderTrackerManager.avaibleCount, perform: { newValue in
            vm.loading = false
        })
        .alert(isPresented: $vm.showCancelAlert, content: {
          Alert(title: Text("Cancel order?"),
                message: Text("Are you sure?"),
                primaryButton: .cancel(Text("Close")),
                secondaryButton: .destructive(Text("Cancel"),
                                              action: {
              vm.loading = true
              if UserDefaults.standard.bool(forKey: "EnableTracking"){

              Amplitude.instance().logEvent("cancel_order",
                                            withEventProperties: ["current_status" : orderTrackerManager.currentState?.state.rawValue])
              }
              vm.cancelOrder(orderID: orderTrackerManager.currentOrder?.id ?? 0) {
//                  if let firstOrder = orderTrackerManager.aviableOrders.first{
//                      orderTrackerManager.currentOrder = firstOrder
//                  }else{
//                      orderTrackerManager.currentOrder = nil
//                  }
                  
                  
              }
          }))
        })
    }
    
    
    @ViewBuilder
    func StateAndDropDounView() -> some View {
        if let currentState = orderTrackerManager.currentState {
            ZStack{
                Text(currentState.state.rawValue)
                    .textCustom(.coreSansC65Bold, 12, Color.col_text_main)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 12)
                    .background(
                        ZStack{
                            currentState.colors.first
                            
                            Capsule()
                                .fill(currentState.colors.last!)
                                .blur(radius: 12)
                                .scaleEffect(CGSize(width: 0.75, height: 0.4))
                                
                        }
                        .clipShape(Capsule())
                    )
                    .overlay(Color.col_black.opacity(detailScrollValue))
                    .hTrailing()
                    .vTop()
                
                
                TrackerDropDownView()
                    .frame(width: 160)
                    .offset(x: 8)
                    .padding(.top, openOrder ? 9 : 0)
                    .opacity(detailScrollValue)
                    .hTrailing()
                    .vTop()
            }
        }
    }
}


struct OrderProductCompactRow: View {
    
    @State var data: OrderDetailsModel
    @State var lightText = false
    
    var body: some View{
        HStack{
            WebImage(url: URL(string: "\(BaseRepository().baseURL)/img/" + data.product.imageLink))
                    .placeholder(
                        Image("Placeholder_Logo")
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .mask(Rectangle()
                            .frame(width: 32, height: 32)
                    )
            
            VStack(alignment: .leading,spacing: 7){
                Text("\(data.product.name)")
                    .textCustom(.coreSansC45Regular, 16, lightText ? Color.col_text_white : Color.col_text_main)

                Text("\(String(format: "%.2f", data.product.gramWeight))g")
                    .textCustom(.coreSansC45Regular, 12, lightText ? Color.col_text_white.opacity(0.7) : Color.col_text_second)

                
            }
            .padding(.leading, 12)
            
            VStack(alignment: .trailing,spacing: 7){
                Text("$\(String(format: "%.2f", data.product.price))")
                    .textCustom(.coreSansC65Bold, 16,  lightText ? Color.col_text_white : Color.col_text_main)
                
                Text("x\(data.quantity)")
                    .textCustom(.coreSansC45Regular, 12, lightText ? Color.col_text_white.opacity(0.7) : Color.col_text_second)

            }
            .hTrailing()
        }
        .padding(16)
    }
}


struct CalculationOrderPriceView: View {
    
    @EnvironmentObject var orderTrackerManager: OrderTrackerManager
    
    @State var lightText = false
    
    @State private var showCalculations = false
    
    var body: some View{
       
        VStack(spacing: 0){
            HStack{
                VStack{
                    Text("Total")
                        .textCustom(.coreSansC65Bold, 16,  Color.col_text_white)
                        .hLeading()
                    
                    Text("\(totalGramWeight())g")
                        .textCustom(.coreSansC45Regular, 12, Color.col_text_white.opacity(0.7))

                        .hLeading()
                        .padding(.top, 2)
                }
                .padding([.top, .bottom, .leading], 16)
                
                Spacer()
                
                Text("$\(orderTrackerManager.currentOrder?.totalSum.formattedString(format: .percent) ?? "")")
                    .textCustom(.coreSansC65Bold, 16,Color.col_text_white)
                
                
                Image("arrow-top")
                    .colorInvert()
                    .rotationEffect(.radians(showCalculations ? .pi * 2 : .pi),
                                    anchor: .center)
                    .padding(.trailing, 16)
                
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    showCalculations.toggle()
                }
            }
            
            CustomDivider()
                .opacity(showCalculations ? 1 : 0)
            
            if let data = orderTrackerManager.currentOrder{
            if showCalculations{
                VStack(spacing: 13){
                    HStack{
                        Text("Product price")
                            .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                        Spacer()
                        
                        Text("$\((data.sum).formattedString(format: .percent) )")
                            .textCustom(.coreSansC45Regular, 16,Color.col_text_white)
                    }
                    HStack{
                        Text("Delivery fee")
                            .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                        Spacer()
                        Text("$10.00")
                            .textCustom(.coreSansC45Regular, 16,Color.col_text_white)
                    }
                    HStack{
                        Text("Excise tax")
                            .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                        Spacer()
                        Text("$\(data.taxSum.formattedString(format: .percent))")
                            .textCustom(.coreSansC45Regular, 16,Color.col_text_white)
                    }
                    HStack{
                        Text("Sale tax")
                            .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                        Spacer()
                        Text("$\(data.salesTaxSum.formattedString(format: .percent))")
                            .textCustom(.coreSansC45Regular, 16,Color.col_text_white)
                    }
                    HStack{
                        Text("Local tax")
                            .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                        Spacer()
                        Text("$\(data.cityTaxSum.formattedString(format: .percent))")
                            .textCustom(.coreSansC45Regular, 16,Color.col_text_white)
                    }
                    if let discount = data.discount, discount.value > 0{
                        HStack{
                            Text(discount.type == .firstOrder ? "First order discount" : "Promo code discount")
                                .textCustom(.coreSansC45Regular, 16,Color.col_green_main)
                            
                            Spacer()
                            
                            Text("-\(discount.measure == .dollar ? "$" : "%")\(discount.value.formattedString(format: .percent))")
                                .textCustom(.coreSansC45Regular, 16, Color.col_green_main)
                        }
                    }
                }
                .padding(15)
            }
            }
        }
    }
    
    
    private func totalGramWeight() -> String {
        var sum = 0.0
        
        for product in orderTrackerManager.currentOrder?.orderDetails ?? [] {
            sum += product.product.gramWeight
        }
        return String(sum)
    }
}

