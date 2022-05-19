//
//  OrderTrackerVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 23.04.2022.
//

import SwiftUI

class OrderTrackerVM: ObservableObject {
    
    @Published var offset: CGFloat = 0
    @Published var lastOffset: CGFloat = 0
    
    @State var firstOpen = true
}
