//
//  OrderTrackerContentView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI


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
                
                if let currentState = orderTrackerManager.currentState, let currentOrder = orderTrackerManager.currentOrder {
                    Text(currentOrder.orderType == .delivery ? currentState.deliveryText : currentState.pickupText)
                    .textCustom(.coreSansC45Regular, 14, Color.col_white.opacity(0.8))
                    .foregroundColor(orderTrackerManager.currentState?.colors.first ?? Color.clear)
                    .padding(.top, 12)
                    .hLeading()
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack{
                        if let license = orderTrackerManager.currentOrder?.license{
                            Text("Order fulfilled by: \(license)")
                                .textCustom(.coreSansC45Regular, 14, Color.col_white.opacity(0.8))
                                .hLeading()
                                .padding(.top,12)
                        }
                        
                        Text("List of items")
                            .textCustom(.coreSansC65Bold, 14, Color.col_text_white.opacity(0.7))
                            .padding(.leading, 11)
                            .padding(.top, 12)
                            
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
                        
                        if let currentOrder = orderTrackerManager.currentOrder{
                            Text(currentOrder.orderType == .delivery ? "Delivery details" : "Pick up at")
                            .textCustom(.coreSansC65Bold, 14, Color.col_text_white.opacity(0.7))
                            .padding(.top, 12)
                            .padding(.leading, 11)
                            .hLeading()
                        }
                        
                        if let currentOrder = orderTrackerManager.currentOrder, currentOrder.orderType == .pickup{

                        //delivery user data
                        VStack(alignment: .leading,spacing: 10){
                            Text(currentOrder.partner.name)
                                .textCustom(.coreSansC45Regular, 14, Color.col_text_white)
                            
                            Text(currentOrder.partner.address)
                                .textCustom(.coreSansC45Regular, 14, Color.col_text_white)
                            
                            Text(currentOrder.partner.phone)
                                .textCustom(.coreSansC45Regular, 14, Color.col_text_white)
                        }
                        .hLeading()
                        .padding()
                        .background(Color.col_white.opacity(0.1).cornerRadius(12))
                        .padding(.top,8)
                        }else{
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
                        }
                        if let currentOrder = orderTrackerManager.currentOrder, currentOrder.orderType == .pickup{
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
                            .padding(.top, 24)
                            .onTapGesture {
                                vm.showDirectionsView = true
                            }
                        }
                        
                        if orderTrackerManager.currentOrder?.state ?? 0 != 7{
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
                            .padding(.top, 8)
                            .onTapGesture {
                                vm.showCancelAlert = true
                                CloudLogger().cloudLog(logData: "Show cancel order Alert", logState: .info)
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
                .customDefaultAlert(title: "Cancel order?", message: "Do you confirm you want to cancel this order?", isPresented: $vm.showCancelAlert, firstBtn: .default(Text("Close")), secondBtn: .destructive(Text("Cancel"), action: {
                    vm.loading = true
                    
                    AnalyticsManager.instance.event(key: .cancel_order,
                                                    properties: [.current_status : orderTrackerManager.currentState?.deliveryState.rawValue])
                    
                    vm.cancelOrder(orderID: orderTrackerManager.currentOrder?.id ?? 0) {
                        vm.loading = false
                    }
                }))
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
        .actionSheet(isPresented: $vm.showDirectionsView) {
            ActionSheet(title: Text("Select app"),
                        buttons: [
                            .default(
                                Text("Google Maps")
                                    .foregroundColor(Color.lightSecondaryE.opacity(1.0))
                                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            ) {
                                guard let store = orderTrackerManager.currentOrder?.partner else {return}
                                Utils.shared.openGoogleMap(address: store.address,lat: store.latitudeCoordinate, lon: store.longitudeCoordinate)
                            },
                            .default(
                                Text("Apple Maps")
                                    .foregroundColor(Color.lightSecondaryE.opacity(1.0))
                                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            ) {
                                guard let store = orderTrackerManager.currentOrder?.partner else {return}
                                Utils.shared.openAppleMap(address: store.address,lat: store.latitudeCoordinate, lon: store.longitudeCoordinate)
                            },
                            .cancel()
                        ])
        }
    }
    
    
    @ViewBuilder
    func StateAndDropDounView() -> some View {
        if let currentState = orderTrackerManager.currentState, let currentOrder = orderTrackerManager.currentOrder {
            ZStack{
                Text(currentOrder.orderType == .delivery ? currentState.deliveryState.rawValue : currentState.pickupState.rawValue)
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
                    .overlay(
                        Image("nft_mini")
                            .resizable()
                            .frame(width: 34, height: 18)
                            .offset(y: -18)
                            .opacity(data.product.isNft ? 1 : 0)
                        ,alignment: .top
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
                    if let type = orderTrackerManager.currentOrder?.orderType, type == .delivery{
                        HStack{
                            Text("Delivery fee")
                                .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                            Spacer()
                            Text("$10.00")
                                .textCustom(.coreSansC45Regular, 16,Color.col_text_white)
                        }
                    }
                    HStack{
                        Text("Excise tax")
                            .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                        Spacer()
                        Text("$\(data.exciseTaxSum.formattedString(format: .percent))")
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

