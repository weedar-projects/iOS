//
//  MyOrderView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 31.03.2022.
//

import SwiftUI


struct MyOrderView: MainLoadViewProtocol {
    @StateObject var vm = MyOrderVM()
    
    @State var id: Int
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var tabBarManager: TabBarManager
    
    @ObservedObject var deepLinksManager = DeepLinks.shared
    
    @State var showLoader: Bool = true
    
    @State var showDeeplink = false
    
    var content: some View {
        
        ZStack{
            
            Color.col_white
            
            VStack{
                //main scroll
                ScrollView(.vertical, showsIndicators: false) {
                    
                    HStack{
                        Text("Status")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                            Spacer()
                        
                        OrderStatusView(status: vm.order?.state ?? 0, isPickup: vm.order?.partner.isPickUp ?? false)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(RadialGradient(colors: [Color.col_gradient_blue_second,
                                                        Color.col_gradient_blue_first],
                                               center: .center,
                                               startRadius: 0,
                                               endRadius: 220)
                                .clipShape(CustomCorner(corners: .allCorners, radius: 12))
                                .opacity(0.25)
                                )
                    .padding([.horizontal, .top],24)
                    
                    if let license = vm.order?.license{
                        Text("Order fulfilled by: \(license)")
                            .textCustom(.coreSansC45Regular, 14, Color.col_text_second)
                            .hLeading()
                            .padding(.top,6)
                            .padding(.horizontal, 35)
                    }
                    
                    Text("List of items")
                        .textCustom(.coreSansC65Bold, 14, Color.col_text_second)
                        .padding(.top, 12)
                        .padding(.leading, 35)
                        .hLeading()
                    
                    //items view
                    VStack(spacing: 0){
                        VStack{
                            ForEach(vm.orderProducts, id: \.self) { product in
                                VStack{
                                    ProductCompactRow(data: product)
                                    
                                    CustomDivider()
                                        .opacity(vm.orderProducts.last != product ? 1 : 0)
                                }
                            }
                        }
                        .background(RadialGradient(colors: [Color.col_gradient_blue_second,
                                                            Color.col_gradient_blue_first],
                                                   center: .center,
                                                   startRadius: 0,
                                                   endRadius: 220)
                                    .clipShape(CustomCorner(corners: .allCorners, radius: 12))
                                    .opacity(0.25)
                                    )
               
                        
                        .padding(.horizontal, 24)
                        
                        if let order = vm.order{
                        //Pricing view
                            CalculationPriceView(data: $vm.orderDetailsReview,showDelivery: order.orderType == .delivery, showDiscount: true)
                            .padding(.top, 24)
                            .padding(.horizontal, 24)
                            .onAppear {
                                print("is pickup \(order.partner.isPickUp)")
                            }
                        }
                        
                        if let isPickUp = vm.order?.orderType{
                            Text(isPickUp == .pickup ? "Pick up at" : "Delivery details")
                                .textCustom(.coreSansC65Bold
                                            , 14, Color.col_text_second)
                                .padding(.top, 24)
                                .padding(.leading, 35)
                                .hLeading()
                        }
                        
                        //delivery user data
                        ZStack{
                            RadialGradient(colors: [Color.col_gradient_blue_second,
                                                    Color.col_gradient_blue_first],
                                           center: .center,
                                           startRadius: 0,
                                           endRadius: 220)
                            .clipShape(CustomCorner(corners: .allCorners, radius: 12))
                            .opacity(0.25)
                            
                            
                            VStack(alignment: .leading,spacing: 10){
                                
                                if let orderType = vm.order?.orderType, let partner = vm.order?.partner, orderType == .pickup{
                                    Text(partner.name)
                                        .textDefault()
                                }else{
                                    Text("\(vm.order?.name ?? "")")
                                        .textDefault()
                                }
                                
                                
                                if let userAddress = vm.order?.addressLine1, let orderType = vm.order?.orderType, orderType == .delivery{
                                    if !userAddress.isEmpty{
                                    Text(userAddress)
                                        .textDefault()
                                    }
                                }
                                
                                if let partner = vm.order?.partner,  let orderType = vm.order?.orderType, orderType == .pickup{
                                    Text(partner.address)
                                        .textDefault()
                                }
                                                                
                                if let partner = vm.order?.partner,  let orderType = vm.order?.orderType, orderType == .pickup{
                                    Text(partner.phone)
                                        .textDefault()
                                }else{
                                    Text("\(vm.order?.phone ?? "")")
                                        .textDefault()
                                }
                             
                            }
                            .padding()
                            .hLeading()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top,8)
                        
                    }
                    .padding(.top, 8)
                    
                    if let orderType = vm.order?.orderType, orderType == .pickup{
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
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        .onTapGesture {
                            vm.showDirectionsView = true
                        }
                        
                    }
                    
                    if let state = vm.order?.state{
                        if  state != 10 && state != 7 && state != 8{
                            Button {
                                vm.showCancelAlert.toggle()
                            } label: {
                                Text("Cancel order")
                                    .textCustom(.coreSansC65Bold, 16, Color.col_pink_button)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.col_bg_second.cornerRadius(12))
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 15)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    deepLinksManager.showDeeplinkView = false
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .padding()
                }
                .opacity(showDeeplink ? 1 : 0)
            }
        }
        .actionSheet(isPresented: $vm.showDirectionsView) {
            ActionSheet(title: Text("Select app"),
                        buttons: [
                            .default(
                                Text("Google Maps")
                                    .foregroundColor(Color.lightSecondaryE.opacity(1.0))
                                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            ) {
                                guard let store = vm.order else {return}
                                Utils.shared.openGoogleMap(address: store.partner.address,lat: store.partner.latitudeCoordinate, lon: store.partner.longitudeCoordinate)
                            },
                            .default(
                                Text("Apple Maps")
                                    .foregroundColor(Color.lightSecondaryE.opacity(1.0))
                                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            ) {
                                guard let store = vm.order else {return}
                                Utils.shared.openAppleMap(address: store.partner.address,lat: store.partner.latitudeCoordinate, lon: store.partner.longitudeCoordinate)
                            },
                            .cancel()
                        ])
        }
        .alert(isPresented: $vm.showCancelAlert, content: {
          Alert(title: Text("Cancel order?"),
                message: Text("Do you confirm you want to cancel this order?"),
                primaryButton: .cancel(Text("Close")),
                secondaryButton: .destructive(Text("Cancel"),
                                              action: {
              self.showLoader = true
              vm.cancelOrder { 
                  vm.getOrder(id: id) {
                      self.showLoader = false
                  }
                  
              }
          }))
        })
        .navBarSettings(vm.getOrderTitle(), backBtnIsHidden: showDeeplink)
        
    }
    
    var loader: some View{
        LoadingScreenMyOrderView()
            .onAppear {
               if vm.firstLoading{
                    vm.getOrderDetails(id) {
                        self.showLoader = false
                        vm.firstLoading = false
                    }
                }
            }
    }
}
