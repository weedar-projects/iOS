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
    
    @State var animProductInCart = false
    
    @State var imageLink: String = ""
    @State var product: ProductModel?
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

                ZStack{
                    HStack{
                        Image("checkmark")
                            .resizable()
                            .frame(width: 13, height: 13)
                            .foregroundColor(Color.col_text_main)
                        
                        Text("Added to cart")
                            .textCustom(.coreSansC65Bold, 16,Color.col_text_main)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Image.bg_gradient_main)
                    .cornerRadius(12)
                    .opacity(animProductInCart ? 1 : 0)
                    
                    HStack{
                        Image("cart")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(Color.col_text_main)
                        
                        Text("Add to cart - $\(product.price.formattedString(format: .percent))")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Image.bg_gradient_main)
                    .cornerRadius(12)
                    .opacity(animProductInCart ? 0 : 1)
                }
                .vBottom()
                .opacity(vm.bgOpacity)
                .padding(.horizontal, 24)
                .padding(.bottom, 8 + getSafeArea().bottom)
                .onTapGesture {
                    vm.notification.notificationOccurred(.success)
                    cartManager.productQuantityInCart(productId: product.id, quantity: .add)
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){
                    Amplitude.instance().logEvent("add_cart_prod_card", withEventProperties: ["category" : product.type.name,
                                                                                              "product_id" : product.id,
                                                                                              "product_qty" : 1,
                                                                                              "product_price" : product.price.formattedString(format: .percent)])
                    }
                    chageAddButtonState()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: vm.showImageFullScreen, perform: { newValue in
            withAnimation {
                self.showImageFullScreen = false
            }
            print("hide photo")
        })
        .gesture(DragGesture().updating($draggingOffset, body: { (value, outValue, _) in
            
            outValue = value.translation
            vm.onChange(value: draggingOffset)
            
        }).onEnded(vm.onEnd(value:)))
        
    }
    func chageAddButtonState(){
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)){
            self.animProductInCart = true
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.animProductInCart = false
            }
        }
    }
}


// Constrains a value between the limits
func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
  min(maxValue, max(minValue, value))
}








