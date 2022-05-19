//
//  OrderDeliveryView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 10.03.2022.
//

import SwiftUI

struct OrderDeliveryView: View {
    
    @ObservedObject var vm = OrderDeliveryVM()
    
    var body: some View {
        ZStack{
            VStack{
                //title
                Text("Delivery details")
                    .lineSpacing(2.8)
                    .modifier(TextModifier(font: .coreSansC45Regular, size: 40, foregroundColor: .lightOnSurfaceB, opacity: 1))
                    .padding([.top, .leading], 24)
                    .hLeading()
                ScrollView(.vertical, showsIndicators: false) {
                   
                    //description
                    Text("Incorrectly entered address may delay your order, so please double check for misprints. Do not enter specific dispatch instruction in any of address fields.")
                        .lineSpacing(2.8)
                        .modifier(TextModifier(font: .coreSansC45Regular, size: 14, foregroundColor: .lightOnSurfaceB, opacity: 0.6))
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .hLeading()
                    
                    CustomTextField(text: $vm.username, state: $vm.usernameTFState, title: "Full Name", placeholder: "Enter your Name")
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
                        TextField("Address", text: $vm.address) { isEditing in
                            self.vm.addressIsEditing = isEditing
                        }
                        .modifier(TextFieldStyles.TextFieldStyle(strokeColor: Binding<Color>.constant(ColorManager.Catalog.Item.backgroundBlue)))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top)
                    
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
                        .frame(height: vm.addressIsEditing && vm.address != "" ? getRect().height / 4 : 0, alignment: .top)
                        .animation(.linear(duration: 0.35))
                }
            }
            
            VStack{
                RequestButton(state: $vm.buttonState, isDisabled: $vm.buttonIsDisabled, title: "welcomeview.welcome_content_next".localized) {
                    
                    vm.saveUserDeliveryAddress(userInfo: vm.userInfo)
                }
                .padding(.bottom, 8)
                
            }
            .background(Color.white)
            .padding(.horizontal, 24)
            .vBottom()
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

struct OrderDeliveryView_Previews: PreviewProvider {
    static var previews: some View {
        OrderDeliveryView()
    }
}
