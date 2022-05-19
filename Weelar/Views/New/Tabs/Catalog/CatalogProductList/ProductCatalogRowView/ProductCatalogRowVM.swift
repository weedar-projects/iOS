//
//  ProductCatalogRowVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 17.03.2022.
//

import SwiftUI

class ProductCatalogRowVM: ObservableObject {

    @Published var productAddToCart = false
    
    let itemViewHeight: CGFloat = 113
    
    @Published var product_qty = 0 
    
    func chageAddButtonState(){
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)){
            productAddToCart = true
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.productAddToCart = false
            }
        }
    }
}
