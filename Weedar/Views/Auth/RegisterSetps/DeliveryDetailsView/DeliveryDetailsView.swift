//
//  DeliveryDetailsView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.03.2022.
//

import SwiftUI

struct DeliveryDetailsView: View {
    
    @StateObject var vm:  DeliveryDetailsVM
    
    @StateObject var rootVM: UserIdentificationRootVM
    
    @EnvironmentObject var cartManager: CartManager
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack{
            VStack{
                //title
                Text("Delivery details")
                    .textTitle()
                    .hLeading()
                    .padding([.top, .leading], 24)
                
                ScrollView(.vertical, showsIndicators: false) {
                   
                    //description
                    Text("Please double check the address to avoid unnecessary delays. It will show if the location \nis eligible for delivery or pick up or both.")
                        .textSecond()
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .hLeading()
                    
                    CustomTextField(text: $vm.username, state: $vm.usernameTFState, title: "Full name", placeholder: "Enter your Full name")
                        .padding(.top, 24)
                    
                    
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
                            self.vm.addressIsEditing = isEditing
                        }
                        .modifier(TextFieldStyles.TextFieldStyle(strokeColor: Binding<Color>.constant(ColorManager.Catalog.Item.backgroundBlue)))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top)
                    
                    if vm.addressIsEditing, vm.address != "", vm.placesCount != 0{
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
                    

                }
            }
            
            VStack{
                MainButton(title: "welcomeview.welcome_content_next".localized) {
                    if vm.validation(){
                        if vm.userInfo.zipCode != nil, vm.userInfo.city != nil{
                            vm.addAdressAndName(userId: sessionManager.user?.id ?? 0,
                                                city: vm.userInfo.city ?? "",
                                                addressLine1: vm.address,
                                                addressLine2: vm.userInfo.addressLine2,
                                                latitudeCoordinate: vm.userInfo.latitudeCoordinate,
                                                longitudeCoordinate: vm.userInfo.longitudeCoordinate,
                                                zipCode: vm.userInfo.zipCode ?? "")
                        }
                    }
                }
                .padding(.bottom, 8)
                
            }
            .background(Color.white)
            .padding(.horizontal, 24)
            .vBottom()
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        
        .onChange(of: vm.stepSuccess) { val in
            rootVM.currentPage = 3
            rootVM.updateIndicatorValue()
        }
    }
}
