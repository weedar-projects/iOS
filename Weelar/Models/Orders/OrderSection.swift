//
//  OrderSection.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct OrderSection: Identifiable {
  var id: UUID = UUID()
  var date: String = ""
  var orders: [OrderResponseModel] = []
}
