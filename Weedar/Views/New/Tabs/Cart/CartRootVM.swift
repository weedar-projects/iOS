//
//  CartRootVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI

class CartRootVM: ObservableObject {
    
    @Published var cartVM = CartVM()
    @Published var emptyCartVM = EmptyCartVM()
    
    @Published var cartIsEmty = false
}

