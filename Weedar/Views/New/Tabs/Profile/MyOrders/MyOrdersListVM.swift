//
//  MyOrdersListVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.04.2022.
//

import SwiftUI
import Alamofire

class MyOrdersListVM: ObservableObject {
    enum OrderType {
        case delivery
        case pickup
    }
    @Published var orderSections: [OrderSectionListModel] = []
    @Published var loading = false
    @Published var selectedTab: OrderType = .delivery{
        didSet{
            getOrderList {}
        }
    }
    
    func getOrderList(comletion: @escaping ()->Void){
        loading = true
        guard let id = UserDefaultsService().get(fromKey: .user) as? Int else {
          print("Can't get ID from Defaults")
          return
        }
        let type = selectedTab == .delivery ? 0 : 1
                
        let endpoint = Routs.getOrdersList.rawValue.appending("\(id)/\(type)")
        
        API.shared.request(endPoint: endpoint) { result in
            
            var orderLocal: [OrderSectionListModel] = []
            
            switch result{
            case let .success(json):
                let orders = json.arrayValue.map({OrderModel(json: $0)})
                orders.forEach { order in
                    guard let createdAt = DateHelper.toDate(order.createdAt) else { return }

                    if orderLocal.isEmpty{
                        orderLocal.append(OrderSectionListModel(date: createdAt, orders: [order]))
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
                      orderLocal.append(OrderSectionListModel(date: createdAt, orders: [order]))
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
                
                self.loading = false
                
            case let .failure(error):
                Logger.log(message: error.localizedDescription, event: .error)
            }
        }
    }
    
}

