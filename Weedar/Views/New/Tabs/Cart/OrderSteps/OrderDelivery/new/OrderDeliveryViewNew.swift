//
//  OrderDeliveryViewNew.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 21.06.2022.
//

import SwiftUI

struct OrderDeliveryView: View {
    
    @StateObject var vm: OrderDeliveryVM
    @StateObject var locationManager = LocationManager()
    
    @Namespace var bottomID
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var orderNavigationManager: OrderNavigationManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        ZStack{
            NavigationLink(isActive: $orderNavigationManager.showOrderReviewView) {
                OrderReviewView()
            } label: {
                Color.clear
            }.isDetailLink(false)
            
            NavigationLink(isActive: $orderNavigationManager.showPickUpView) {
                PickUpRootView()
            } label: {
                Color.clear
            }.isDetailLink(false)
            
            Color.white
            
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { reader in
                    VStack{
                        //description
                        VStack{
                            Text(vm.descriptionText)
                                .lineSpacing(2.8)
                                .textCustom(.coreSansC45Regular, 16, Color.col_text_second)
                                .animation(.none, value: vm.currentOrderType)
                                .vTop()
                        }
                        .frame(height: 70)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .hLeading()
                        
                        //order type picker
                        OrderTypePicker()
                            .padding(.top, 7)
                        
                        //User name text field
                        NameTextField()
                            .padding(.top, 24)
                        
                        if !vm.userNameError.isEmpty{
                            Text(vm.userNameError)
                                .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
                                .padding(.leading, 36)
                                .padding(.top, 10)
                                .hLeading()
                        }
                        
                        //Address text field
                        AddressTextField()
                            .padding(.top, 24)
                            .onTapGesture {
                                vm.tapToAddressField()
                            }
                        
                        if !vm.addressError.isEmpty{
                            Text(vm.addressError)
                                .textCustom(.coreSansC45Regular, 14, Color.col_pink_main)
                                .padding(.leading, 36)
                                .padding(.top, 10)
                                .hLeading()
                        }
                        
                        AddressList()
               
                            
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 1, height: 5)
                            .id(bottomID)
                        
                        Spacer()
                    }
                    .onChange(of: vm.userAddress) { address in
                        if address.count >= 3{
                            reader.scrollTo(bottomID)
                        }
                    }
                }
            }
            ZStack{
                VStack{
                    
                    Text(vm.infoText)
                        .textDefault()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .animation(.none, value: vm.infoText)
                    
                    
                    if vm.currentOrderType == .delivery || vm.currentOrderType == .none{
                        RequestButton(state: $vm.createOrderButtonState, isDisabled: $vm.createOrderButtonIsDisabled, showIcon: false, title: "Review order") {
                            vm.disableNavButton = true
                            if vm.needToUploadDocuments(){
                                vm.saveUserData {
                                    orderNavigationManager.needToShowDocumentCenter = true
                                    vm.disableNavButton = false
                                }
                            }else{
                                self.vm.saveDataCreateOrder { order in
                                    sessionManager.userData(withUpdate: true)
                                    orderNavigationManager.currentCreatedOrder = vm.getCreatedOrder(order: order)
                                    orderNavigationManager.orderType = .delivery
                                    orderNavigationManager.showOrderReviewView = true
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                    } else {
                        MainButton(title: "Choose store") {
                            if vm.needToUploadDocuments(){
                                vm.saveUserData {
                                    orderNavigationManager.needToShowDocumentCenter = true
                                }
                            }else{
                                vm.saveUserData(){
                                    orderNavigationManager.showPickUpView = true
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                    }
                }
                .background(Color.col_white)
                .padding(.bottom, isSmallIPhone() ? 16 : 0)
                .vBottom()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationTitle("Order details")
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
                        tabBarManager.show()
                        self.mode.wrappedValue.dismiss()
                    }
                }
            }
        })
        .alert(isPresented: $vm.showAlert) {
            switch vm.activeAlert {
            case .error:
                return Alert(title:
                                Text("Error"),
                             message:
                                Text(vm.messageAlertError),
                             dismissButton: .cancel(Text("OK"))
                )
            case .location:
                return Alert(title:
                                Text("Location sercices are off"),
                             message:
                                Text("To use your current location, please\nenable location services in Settings."),
                             primaryButton: .default(Text("Not right now"), action: {
                    vm.showAlert = false
                }),
                             secondaryButton: .default(Text("Go to Settings"), action: {
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
                )
            }
        }
        .fullScreenCover(isPresented: $orderNavigationManager.needToShowDocumentCenter, onDismiss: {
               }, content: {
                   NavigationView{
                       DocumentCenterView { documentLoaded in
                           if documentLoaded{
                               sessionManager.userData(withUpdate: true) { user in
                                   vm.userData = user
                               }
                               vm.createOrderButtonState = .success
                               vm.saveDataCreateOrder { order in
                                   sessionManager.userData(withUpdate: true)
                                   orderNavigationManager.currentCreatedOrder = vm.getCreatedOrder(order: order)
                                   orderNavigationManager.orderType = .delivery
                                   if vm.currentOrderType == .delivery{
                                       orderNavigationManager.showOrderReviewView = true
                                   } else {
                                       orderNavigationManager.showPickUpView = true
                                   }
                                   
                               }
                           }
                       }
                       .navBarSettings("Document center", backBtnIsHidden: true)
                       .onDisappear {
                           vm.createOrderButtonState = .def
                       }
                   }
               })
        .onAppear{
            sessionManager.userData(withUpdate: true) { user in
                vm.userData = user
                vm.validation(appear: true)
            }
            if locationManager.authorisationStatus != .authorizedAlways{
                locationManager.requestAuthorisation(always: true)
            }
        }
    }
    
    //MARK: ORDER TYPE PICKER
    @ViewBuilder
    func OrderTypePicker() -> some View {
        HStack(spacing: 0){
            Text("Delivery")
                .textCustom(.coreSansC65Bold, 16, vm.pickerDeliveryTextColor)
                .frame(width: (getRect().width / 2 - 24) - 0.5, height: 44)
                .background(Color.col_white.opacity(0.01))
                .onTapGesture {
                    if vm.deliveryAvailable{
                        withAnimation {
                            vm.currentOrderType = vm.currentOrderType == .delivery ? .none : .delivery
                        }
                    }
                }
            
            Rectangle()
                .fill(Color.col_borders)
                .frame(width: 1, height: 44)
            
            Text("Pick up")
                .textCustom(.coreSansC65Bold, 16, vm.pickerPickUpTextColor)
                .frame(width: (getRect().width / 2 - 24), height: 44)
                .background(Color.col_white.opacity(0.01))
                .onTapGesture {
                    if vm.pickUpAvailable{
                        withAnimation {
                            vm.currentOrderType = vm.currentOrderType == .pickup ? .none : .pickup
                        }
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .background(
                HStack{
                    vm.pickerSelectorBackgroudColor
                        .frame(width: (getRect().width / 2 - 24) - 0.5, height: 44)
                        .cornerRadius(radius: 12, corners: vm.pickerSelectoreCornerShape)
                        .animation(vm.currentOrderType == .none ? .none : .interactiveSpring(response: 0.15,
                                                      dampingFraction: 0.65,
                                                                                             blendDuration: 1.5),
                                   value: vm.currentOrderType != .none)
                        .offset(x: vm.pickerSelectoreCurrentXLocation)
                        .hLeading()
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder()
                .foregroundColor(Color.col_borders)
        )
        .padding(.horizontal, 24)
        
    }
    
    
    @ViewBuilder
    func NameTextField() -> some View {
        VStack{
            Text("Full name")
                .hLeading()
                .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 14))
                .padding(.leading, 12)
                .opacity(0.7)
        ZStack{
            TextField("Enter your name", text: $vm.userName) { isEditing in
                if !isEditing{
                    vm.validation()
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 48)
        .overlay(
            //color
                RoundedRectangle(cornerRadius: 12)
                    .stroke(vm.nameStrokeColor, lineWidth: 2)
                    .frame(height: 48)
            )
        }
        .padding(.horizontal,24)
        .onChange(of: vm.userNameTFState) { newValue in
            switch newValue{
            case .def:
                vm.nameStrokeColor = Color.col_borders
            case .success:
                vm.nameStrokeColor = Color.col_green_second
            case .error:
                vm.nameStrokeColor = Color.col_red_second
            }
        }

        
    }
    
    //MARK: ADDRESS TF
    @ViewBuilder
    func AddressTextField() -> some View{
        VStack{
            Text("Address")
                .hLeading()
                .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 14))
                .padding(.leading, 12)
                .opacity(0.7)
            
            ZStack{
                TextField("Enter your address", text: $vm.userAddress) { isEditing in
                    vm.showAddressList = isEditing
                }
                .padding(.horizontal, 12)
                .onChange(of: vm.userAddress) { newAddressText in
                    vm.getGoogleAddressPrompt(addressText: newAddressText)
                }
            }
            .frame(height: 48)
            .overlay(
                //color
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vm.addressStrokeColor, lineWidth: 2)
                        .frame(height: 48)
                )
            .overlay(
                ProgressView()
                    .frame(width: 16, height: 16)
                    .padding(.trailing, 12)
                    .opacity(vm.locationIsLoading ? 1 : 0)
                , alignment: .trailing)
            .onTapGesture {
                vm.locationIsLoading = false
            }
        }
        .padding(.horizontal, 24)
        .onChange(of: vm.userAddressTFState) { newValue in
            switch newValue{
            case .def:
                vm.addressStrokeColor = Color.col_borders
            case .success:
                vm.addressStrokeColor = Color.col_green_second
            case .error:
                vm.addressStrokeColor = Color.col_red_second
            }
        }
    }
    
    //MARK: ADDRESS LIST
    @ViewBuilder
    func AddressList() -> some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            if vm.showAddressList{
                HStack(spacing: 0){
                    Image("mapMarker_icon")
                        .scaleEffect(0.8)
                    Text("Use my current location")
                        .padding(.leading, 10)
                        .font(.system(size: 16))
                        .foregroundColor(Color.col_blue_main)
                        .hLeading()
                }
                .padding(.top,10)
                .padding(.horizontal, 26)
                .background(Color.white.frame(width: getRect().width))
                .onTapGesture {
                    vm.locationIsLoading = true
                    if locationManager.authorisationStatus == .denied{
                        vm.activeAlert = .location
                        vm.showAlert = true
                        vm.locationIsLoading = false
                    }
                    locationManager.requestLocation { currentAddress, zipcode in
                        vm.userAddress = currentAddress
                        vm.zipCode = zipcode
                        vm.validation()
                        vm.locationIsLoading = false
                        hideKeyboard()
                    }
                        
                }
            }
            if let predictions = vm.addressListPlaces?.predictions, vm.userAddress.count>=3, vm.showAddressList {
                Divider()
                    .padding(.horizontal, 36)
                ForEach(predictions, id: \.self) { item in
                    VStack(alignment: .leading){
                        Text("\(item.predictionDescription)")
                            .foregroundColor(.black)
                            .onTapGesture {
                                vm.tapToGoogleAddress(placeID: item.placeID)
                                vm.showAddressList = false
                                UIApplication.shared.endEditing()
                            }
                        Divider()
                    }
                    .padding(.horizontal, 36)
                }
            }
        })
        .frame(height: getRect().height / 4, alignment: .top)
    }
}

struct AlertInfo: Identifiable {
    enum AlertType {
        case one
        case two
    }
    
    let id: AlertType
    let title: String
    let message: String
}
