//
//  OrderSectionListModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI


struct OrderSectionListModel: Identifiable {
    var id = UUID().uuidString
    var date: String = ""
    var orders: [OrderModel] = []
}
