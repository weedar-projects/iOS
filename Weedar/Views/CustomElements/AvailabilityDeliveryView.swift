//
//  AvailabilityDeliveryView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 13.03.2022.
//

import SwiftUI

enum AvailabityDeliveryState {
    case success
    case notFound
    case def
}

struct AvailabilityDeliveryView: View {
    
    @Binding var deliveryState: AvailabityDeliveryState
    @Binding var pickUpState: AvailabityDeliveryState
    
    @State private var borderColorDelivery = Color.textFieldGray
    @State private var textColorDelivery = Color.textFieldGray
    
    @State private var borderColorPickUp = Color.textFieldGray
    @State private var textColorPickUp = Color.textFieldGray
    
    @EnvironmentObject var tabbarManager: TabBarManager
    
    var body: some View{
        HStack{
            HStack{
                if deliveryState == .success{
                    Image("checkmark")
                        .resizable()
                        .frame(width: 11, height: 10)
                        .foregroundColor(Color.col_green_main)
                        
                } else if deliveryState == .notFound{
                    Image(systemName: "xmark")
                        .foregroundColor(Color.col_pink_button)
                        .font(.system(size: 11))
                }
                
                Text("Delivery")
                    .textCustom(.coreSansC45Regular, 14, textColorDelivery)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColorDelivery, lineWidth: 2)
                    .frame(width: (getRect().width / 2.4) ,height: 40)
            )
            .frame(width: (getRect().width / 2.4) ,height: 40)
            
            Spacer()
            
            NavigationLink {
                PickUpRootView()
            } label: {
                Text("Pick up")
                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 14))
                    .foregroundColor(textColorPickUp)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColorPickUp, lineWidth: 2)
                            .frame(width: (getRect().width / 2.4) ,height: 40)
                    )
                    .frame(width: (getRect().width / 2.4) ,height: 40)
            }
            .isDetailLink(false)
        }
        .onChange(of: deliveryState) { newValue in
            switch newValue {
            case .def:
                self.borderColorDelivery = Color.textFieldGray
                self.textColorDelivery = Color.textFieldGray
            case .success:
                self.borderColorDelivery = Color.col_green_second
                self.textColorDelivery = Color.col_green_main
            case .notFound:
                self.borderColorDelivery = Color.col_gradient_pink_first
                self.textColorDelivery = Color.col_pink_button
            }
        }
        .onChange(of: pickUpState) { newValue in
            switch newValue {
            case .def:
                self.borderColorPickUp = Color.textFieldGray
                self.textColorPickUp = Color.textFieldGray
            case .success:
                self.borderColorPickUp = Color.lightSecondaryF
                self.textColorPickUp = Color.lightSecondaryF
            case .notFound:
                self.borderColorPickUp = Color.textFieldGray
                self.textColorPickUp = Color.lightSecondaryC
            }
        }
        .onAppear(){
            switch deliveryState {
            case .def:
                self.borderColorDelivery = Color.textFieldGray
                self.textColorDelivery = Color.textFieldGray
            case .success:
                self.borderColorDelivery = Color.col_green_second
                self.textColorDelivery = Color.col_green_main
            case .notFound:
                self.borderColorDelivery = Color.textFieldGray
                self.textColorDelivery = Color.col_pink_button
            }
        }
    }
}
