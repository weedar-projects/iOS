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
                        
                        OrderStatusView(status: vm.order?.state ?? 0)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(Color.col_bg_second.cornerRadius(12))
                    .padding([.horizontal, .top],24)
                    
                    Text("List of items")
                        .textCustom(.coreSansC65Bold, 14, Color.col_text_second)
                        .padding(.top, 24)
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
                        .background(Color.col_bg_second.cornerRadius(12))
               
                        
                        .padding(.horizontal, 24)
                        
                        //Pricing view
                        CalculationPriceView(data: $vm.orderDetailsReview, showDiscount: true)
                            .padding(.top, 24)
                            .padding(.horizontal, 24)
                        
                        Text("Delivery details")
                            .textCustom(.coreSansC65Bold
                                        , 14, Color.col_text_second)
                            .padding(.top, 24)
                            .padding(.leading, 35)
                            .hLeading()
                        
                        //delivery user data
                        ZStack{
                            Color.col_bg_second
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading,spacing: 10){
                                Text("\(vm.order?.name ?? "")")
                                    .textDefault()
                                
                                Text("\(vm.order?.addressLine1 ?? "")")
                                    .textDefault()
                                
                               // Text("\(vm.order?.zipCode ?? "")")
                                 //   .textDefault()
                                
                                Text("\(vm.order?.phone ?? "")")
                                    .textDefault()
                            }
                            .padding()
                            .hLeading()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top,8)
                        
                    }
                    .padding(.top, 8)
                    if let state = vm.order?.state{
                        if  state != 10 && state != 7{
                            Button {
                                vm.showCancelAlert.toggle()
                            } label: {
                                Text("Cancel order")
                                    .textCustom(.coreSansC65Bold, 16, Color.col_red_main)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.col_bg_second.cornerRadius(12))
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 24)
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
        .alert(isPresented: $vm.showCancelAlert, content: {
          Alert(title: Text("Cancel order?"),
                message: Text("Are you sure?"),
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
