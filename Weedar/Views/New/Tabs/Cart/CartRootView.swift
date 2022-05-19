//
//  CartRootView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI
import RealityKit

struct CartRootView: View {
    
    
    @ObservedObject var vm  = CartRootVM()
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var body: some View {
        NavigationView{
            if let cart = cartManager.cartData{
                if !cart.cartDetails.isEmpty{
                    CartView(vm: vm.cartVM, cartRootVM: vm)
                        .navBarSettings("Cart", backBtnIsHidden: true)
                }else{
                    EmptyCartView(vm: vm.emptyCartVM)
                        .navBarSettings("Cart", backBtnIsHidden: true)
                }
            }else{
                LoadingScreenCart()
            }
        }
        .id(tabBarManager.navigationIds[1])
        .navigationBarTitleDisplayMode(.large)
        .onUIKitAppear {
            cartManager.getCart()
            tabBarManager.show()
        }
    }
}

struct CartRootView_Previews: PreviewProvider {
    static var previews: some View {
        CartRootView()
    }
}
