//
//  MyOrderVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 31.03.2022.
//

import SwiftUI
import SwiftyJSON

class MyOrderVM: ObservableObject {

    @Published var orderProducts: [CartProduct] = []
    @Published var order: OrderResponseModel?
    @Published var navTitle: String = ""
    @Published var orderDetailsReview: OrderDetailsReview = OrderDetailsReview(orderId: 0, totalSum: 0, exciseTaxSum: 0, salesTaxSum: 0, localTaxSum: 0, taxSum: 0, state: 0)
    
    func getOrderDetails (_ orderId: Int) {
        
        OrderRepository.shared.getOrderDetails(orderId: orderId) { result in
            switch result {
                case .success(let item):
                    item.forEach { details in
                        self.orderProducts.append(CartProduct(id: orderId, item: details.product, quantity: details.quantity,imageLink: details.product.imageLink))
                    }
                self.getOrder(id: orderId)
                case .failure(let error):
                    print(error)
            }
        }
        
        
    }
    
    func getOrder(id: Int) {
        let endpoint = Routs.getOrderById.rawValue.appending("/\(id)")
        API.shared.request(endPoint: endpoint) { result in
            switch result{
            case let .success(json):
                
                let id = json["id"].intValue
                let totalSum = json["totalSum"].doubleValue
                let exciseTaxSum = json["exciseTaxSum"].doubleValue
                let salesTaxSum = json["salesTaxSum"].doubleValue
                let cityTaxSum = json["cityTaxSum"].doubleValue
                let taxSum = json["taxSum"].doubleValue
                let state = json["state"].intValue
                self.orderDetailsReview = OrderDetailsReview(orderId: id, totalSum: totalSum,exciseTaxSum: exciseTaxSum, totalWeight: self.totalGramWeight().formattedString(format: .percent), salesTaxSum: salesTaxSum, localTaxSum: cityTaxSum, taxSum: taxSum, state: state)
                
                
                self.order = OrderResponseModel(json: json)
                
                print("order: \(json)")
            case let .failure(error):
                print("error: \(error)")
                break
            }
        }
        
    }
    
    //Get total gram in product
     func totalGramWeight() -> Double {
         var sum = 0.0
         
         for product in orderProducts {
             sum += product.totalProductsGramWeight
         }
         return sum
     }
}

//struct OrderModel {
//    var orderId: Int
//    var totalSum: Double
//    var exciseTaxSum: Double
//    var salesTaxSum: Double
//    var localTaxSum: Double
//    var taxSum: Double
//    var state: Int
//    var products: [ProductModel]
//    var quantity: Int
//    init(json: JSON) {
//        self.orderId = json["id"].intValue
//        self.totalSum = json["totalSum"].doubleValue
//        self.exciseTaxSum = json["exciseTaxSum"].doubleValue
//        self.salesTaxSum = json["salesTaxSum"].doubleValue
//        self.localTaxSum = json["cityTaxSum"].doubleValue
//        self.taxSum = json["taxSum"].doubleValue
//        self.state = json["state"].intValue
//        self.products = json["detail"].arrayValue.map({ ProductModel(json: $0) })
//    }
//}
