//
//  PhotoFullScreenView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 08.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import Amplitude

struct ImagesFullScreenView: View {
    
    @StateObject var vm = ImagesFullScreenVM()
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    @GestureState var draggingOffset: CGSize = .zero
    
    @State var imageLink: String = ""
    @State var product: ProductModel
    @Binding var showImageFullScreen: Bool
    
    @State private var dragged = CGSize.zero
       @State private var accumulated = CGSize.zero
    
    var body: some View {
        ZStack{
            Color.col_black
                .opacity(vm.bgOpacity)
                .ignoresSafeArea()
            
           
            WebImage(url: URL(string: "\(BaseRepository().baseURL)/img/" + imageLink))
                                .placeholder(
                                    Image("Placeholder_Logo")
                                )
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .zoomable(scale: $vm.imageScale)
                                .opacity(vm.bgOpacity)
            
            
            if let product = product {
                MainButton(title: "Add to Cart - $\(product.price.formattedString(format: .percent))", icon: "cart", iconSize: 18) {
                    cartManager.productQuantityInCart(productId: product.id, quantity: .add)
                    vm.notification.notificationOccurred(.success)
                }
                .vBottom()
                .opacity(vm.bgOpacity)
                .padding(.horizontal, 24)
                .padding(.bottom, 8 + getSafeArea().bottom)
                
            }
        }
        .onTapGesture {
            vm.notification.notificationOccurred(.success)
            cartManager.productQuantityInCart(productId: product.id, quantity: .custom(vm.quantity))
            if UserDefaults.standard.bool(forKey: "EnableTracking"){

            Amplitude.instance().logEvent("add_cart_prod_card_full_screen", withEventProperties: ["category" : product.type.name,
                                                                                      "product_id" : product.id,
                                                                                      "product_qty" : vm.quantity,
                                                                                      "product_price" : product.price.formattedString(format: .percent)])
            }
            vm.chageAddButtonState()
        }.disabled(vm.animProductInCart)
        
    }
}


// Constrains a value between the limits
func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
  min(maxValue, max(minValue, value))
}








