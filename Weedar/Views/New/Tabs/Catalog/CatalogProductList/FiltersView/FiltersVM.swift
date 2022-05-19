//
//  FiltersVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 04.04.2022.
//

import SwiftUI
import SwiftyJSON

class FiltersVM: ObservableObject {

    @Published var priceFrom: CGFloat = 0
    @Published var priceTo: CGFloat = 299
    
}
