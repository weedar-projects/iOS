//
//  OrderDeliveryView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 10.03.2022.
//

import SwiftUI
import Amplitude

struct OrderDeliveryView: View {
    
    
    @StateObject var vm: OrderDeliveryVM
    
    @EnvironmentObject var cartManager: CartManager
    
    @EnvironmentObject var tabBarManager: TabBarManager

    @EnvironmentObject var orderNavigationManager: OrderNavigationManager
    
    @EnvironmentObject var sessionManager: SessionManager
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @State var showDelivery = false
    
    var body: some View {
        ZStack{
            NavigationLink(isActive: $orderNavigationManager.showOrderReviewView) {
                OrderReviewView(data: vm.orderDetailsReview ?? OrderDetailsReview(orderId: 0, totalSum: 0, exciseTaxSum: 0, salesTaxSum: 0, localTaxSum: 0, discount: nil, taxSum: 0, sum: 0, state: 0))
            } label: {
                Color.clear
            }.isDetailLink(false)
            
            
            Color.white
            
            VStack{
                
                ScrollView(.vertical, showsIndicators: false) {
                    //description
                    Text("Please double check the address to avoid unnecessary delays. It will show if the location \nis eligible for delivery or pick up or both.")
                        .lineSpacing(2.8)
                        .textSecond()
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .hLeading()
                    
                    CustomTextField(text: $vm.name, state: $vm.usernameTFState, title: "Full name", placeholder: "Enter your Full name")
                        .padding(.top, 24)
                        .onChange(of: vm.name) { newValue in
                            if newValue.isEmpty{
                                vm.usernameTFState = .error
                                vm.validName = false
                            }else{
                                vm.usernameTFState = .success
                                vm.validName = true
                            }
                        }
                        .onAppear(){
                            if vm.name != ""{
                                vm.usernameTFState = .success
                                vm.validName = true
                            }
                        }
                    
                    
                    VStack{
                        Text("Availability")
                            .hLeading()
                            .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 14))
                            .padding(.leading, 12)
                            .opacity(0.7)
                        
                        AvailabilityDeliveryView(deliveryState: $vm.deliveryState,
                                                 pickUpState: $vm.pickUpState)
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.top)
                    
                    // Address Textfield
                    VStack{
                        Text("Address")
                            .hLeading()
                            .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 14))
                            .padding(.leading, 12)
                            .opacity(0.7)
                        
                        TextField("Enter your address", text: $vm.address) { isEditing in
                            showDelivery = isEditing
                        }
                        .modifier(TextFieldStyles.TextFieldStyle(strokeColor: Binding<Color>.constant(vm.addressTFState == .success ? Color.col_green_second.opacity(0.6) : vm.addressTFState == .error ?  Color.col_gradient_pink_first .opacity(0.6): vm.addressTFState == .def ?  Color.col_borders : Color.clear)))
                      
                    }
                    .padding(.horizontal, 24)
                    .padding(.top)
                    .onTapGesture(perform: {
                        vm.address = ""
                        vm.addressTFState = .def
                        vm.addressErrorMessage = ""
                        vm.deliveryState = .def
                    })
                    
                    if showDelivery, vm.address != "", vm.placesCount != 0{
                    ScrollView(.vertical, showsIndicators: true, content: {
                        ForEach(vm.places?.predictions ?? [], id: \.self) { item in
                            VStack(alignment: .leading){
                                Text("\(item.predictionDescription)")
                                    .foregroundColor(.black)
                                    .onTapGesture {
                                        vm.selectionPlace = nil
                                        vm.address = ""
                                        vm.addressIsEditing = false
                                        vm.selectionPlace = item
                                        UIApplication.shared.endEditing()
                                    }
                                Divider()
                            }
                            .padding(.horizontal, 36)
                        }
                    })
                        .frame(height: getRect().height / 4, alignment: .top)
                        .animation(.linear(duration: 0.35))
                    }
                    
                    if !vm.addressErrorMessage.isEmpty{
                        Text(vm.addressErrorMessage)
                            .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
                            .padding(.leading, 36)
                            .padding(.top, 10)
                            
                            .hLeading()
                    }
                    
                }

            }
            
            VStack{
                Text("Our courier will ask you to show your ID card \nto verify your identity and age.")
                    .textDefault()
                    .multilineTextAlignment(.center)
                
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, showIcon: false, title: "Review order") {
                    vm.disableNavButton = true
                    if vm.needToLoadDoc{
                        vm.saveUserInfo()
                        orderNavigationManager.needToShowDocumentCenter = true
                        vm.disableNavButton = false
                    }else{
                        self.makeOrder()
                        print("MAKE ORdeRrr")
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 24)
            }
            .background(Color.col_white)
            .vBottom()
            
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle("Delivery details")
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                ZStack{
                    Image("backNavBtn")
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                .onTapGesture {
                    print(vm.disableNavButton)
                    if !vm.disableNavButton{
                        self.mode.wrappedValue.dismiss()
                    }
                }
            }
        })
        .onAppear {
            tabBarManager.hide()
            vm.validName = !vm.name.isEmpty
            vm.zipcodeAndNameValidation()
            sessionManager.userData { user in
                if user.passportPhotoLink.isEmpty{
                    vm.needToLoadDoc = true
                }else{
                    vm.needToLoadDoc = false
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: vm.buttonIsDisabled, perform: { newValue in
            vm.disableNavButton = newValue
        })
        .onDisappear(perform: {
            if !orderNavigationManager.showOrderReviewView{
                tabBarManager.show()
            }
        })
        .alert(isPresented: $vm.checkoutAlertShow, content: {
            Alert(title: Text("Order creation failed"),
                  message: Text(vm.errorMessage),
                  dismissButton: .default(Text("OK")))
        })
        .fullScreenCover(isPresented: $orderNavigationManager.needToShowDocumentCenter, onDismiss: {
               }, content: {
                   NavigationView{
                       DocumentCenterView { documentLoaded in
                           if documentLoaded{
                               makeOrder()
                           }
                       }
                       .navBarSettings("Document center", backBtnIsHidden: true)
                       .onDisappear {
                           vm.buttonState = .def
                       }
                   }
               })
    }
    
    func makeOrder(){
        if vm.validation(){
            vm.buttonState = .loading
            vm.saveUserInfo()
            if let cartData = cartManager.cartData{
            vm.composeOrder(name: self.vm.name, sum: cartData.totalSum) { result in
                switch result {
                case true :
                    vm.makeOrder(userInfo: vm.userInfo,
                                 cartProducts: cartData.cartDetails) {
                        result, message in
                        if !result {
                            self.vm.errorMessage = message
                            self.vm.checkoutAlertShow = true
                            if UserDefaults.standard.bool(forKey: "EnableTracking"){
                            Amplitude.instance().logEvent("order_creation_fail", withEventProperties: ["order_creation_fail" : vm.errorMessage])
                            }
                            vm.disableNavButton = false
                            vm.addressTFState = .success
                            
                        } else {
                            orderNavigationManager.showOrderReviewView = true
                            vm.addressTFState = .success
                            if UserDefaults.standard.bool(forKey: "EnableTracking"){

                            Amplitude.instance().logEvent("review_order_success")
                            }
                            vm.disableNavButton = false
                        }
                        vm.buttonState = .def
                    }
                case false :
                    vm.disableNavButton = false
                    vm.errorMessage = "Please provide more detailed address."
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){

                    Amplitude.instance().logEvent("order_creation_fail", withEventProperties: ["order_creation_fail" : vm.errorMessage])
                    }
                    self.vm.checkoutAlertShow = true
                    vm.buttonState = .def
                    vm.addressTFState = .error
                    
                }
            }
            }
        }
    }
}
