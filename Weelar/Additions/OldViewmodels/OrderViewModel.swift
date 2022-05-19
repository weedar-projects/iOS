//
//  OrderViewModel.swift
//  Weelar
//
//  Created by vtsyomenko on 20.08.2021.
//

import Foundation
import SwiftUI

final class OrderViewModel: ObservableObject {

  @Published var orderSections: [OrderSection] = []
  
    init(profileIsActive: Binding<Bool>? = nil, ordersViewIsActive: Binding<Bool>? = nil, selectedOrderId: Binding<Int>? = nil) {
  }
  
func getOrders() {
      
    guard let id = UserDefaultsService().get(fromKey: .user) as? Int else {
      print("Can't get ID from Defaults")
      return
    }
    
    OrderRepository
      .shared
      .getOrders(userId: id) { [weak self] result in
        guard let self = self else { return }
        
        var orderLocal: [OrderSection] = []
        
        switch result {
          case .success(let orders):
            DispatchQueue.main.async {
              orders.forEach { order in
                  print("orders: \(orders)")
                  
                guard let createdAt = DateHelper.toDate(order.createdAt) else { return }

                if orderLocal.isEmpty {
                  orderLocal.append(OrderSection(date: createdAt, orders: [order]))
                  return
                }

                let lastElement = orderLocal.last!
                let addedDate = lastElement.date == createdAt
                
                if addedDate {
                  let index = orderLocal.firstIndex { section in
                    return section.date == createdAt
                  }
                  
                  orderLocal[index!].orders.append(order)
                } else {
                  orderLocal.append(OrderSection(date: createdAt, orders: [order]))
                }
              }

                self.orderSections = orderLocal.sorted { s1, s2 in
                    if let d1 = s1.date.toDate(),
                       let d2 = s2.date.toDate() {
                        return d1 > d2
                    } else {
                        return s1.date > s2.date
                    }
                }
            }
            
          case .failure(let error):
            Logger.log(message: error.localizedDescription, event: .error)
        }
      }
  }
}
