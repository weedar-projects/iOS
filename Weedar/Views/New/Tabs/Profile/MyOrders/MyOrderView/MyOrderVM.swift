//
//  MyOrderVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 31.03.2022.
//

import SwiftUI
import SwiftyJSON

struct OrderDetailModel: Hashable{
    var quantity: Int
    var product: ProductModel
    
    init(json: JSON) {
        self.quantity = json["quantity"].intValue
        self.product = ProductModel(json: json["product"])
    }
    
    init(quanity: Int ,product: ProductModel){
        self.quantity = quanity
        self.product = product
    }
}

class MyOrderVM: ObservableObject {

    @Published var orderProducts: [OrderDetailModel] = []
    @Published var order: OrderResponseModel?
    @Published var navTitle: String = ""
    @Published var orderDetailsReview: OrderDetailsReview = OrderDetailsReview(orderId: 0, totalSum: 0, exciseTaxSum: 0, salesTaxSum: 0, localTaxSum: 0, discount: nil, taxSum: 0, sum: 0, state: 0, fullAdress: "",username: "",phone: "", partnerPhone: "", partnerName: "", partnerAdress: "", orderNumber: "")
    
    @Published var showCancelAlert = false
   
    @Published var firstLoading = true
    
    @Published var showDirectionsView = false
    
    func getOrderDetails(_ orderId: Int, comletion: @escaping ()->Void){
        guard orderId != 0 else { return }

        let endPoint = "/orderDetail/order/\(orderId)"
     
        API.shared.request(endPoint: endPoint, method: .get) { result in
            switch result{
            case .success(let json):
                let orderDetail =  json.arrayValue.map({OrderDetailModel(json: $0)})
                self.orderProducts = orderDetail
                self.getOrder(id: orderId) {
                    comletion()
                }
            case .failure(let error):
                print("error to load order \(error)")
            }
        }
    }
    
    func getOrder(id: Int, comletion: @escaping ()->Void) {
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
                let discount = DiscountModel(json: json["discount"]) 
                let state = json["state"].intValue
                let sum = json["sum"].doubleValue
                
                let name = json["name"].stringValue
                let phone = json["phone"].stringValue
                let addressLine1 = json["addressLine1"].stringValue
                let licence = json["license"].stringValue
                self.orderDetailsReview =  OrderDetailsReview(orderId: id, totalSum: totalSum, exciseTaxSum: exciseTaxSum, totalWeight: self.totalGramWeight().formattedString(format: .percent), salesTaxSum: salesTaxSum, localTaxSum: cityTaxSum, discount: discount, taxSum: taxSum, sum: sum, state: state,fullAdress: addressLine1,username: name,phone: phone,partnerPhone: "", partnerName: "", partnerAdress: "", licence: licence, orderNumber: "")
                
                self.order = OrderResponseModel(json: json)
                comletion()
                print("order: \(json)")
            case let .failure(error):
                print("error: \(error)")
                break
            }
        }
    }
    
    func cancelOrder(completion: @escaping () -> Void){
        let endPoint = "/order/\(order?.id ?? 0)/cancel"
        
        API.shared.request(endPoint: endPoint, method: .put) { result in
            switch result {
            case .success(_):
                completion()
            case .failure(_):
                completion()
            }
        }
    }
    
    //Get total gram in product
     func totalGramWeight() -> Double {
         var sum = 0.0
         
         for product in orderProducts {
             sum += product.product.gramWeight
         }
         return sum
     }
    
    func getOrderTitle() -> String {
        if let ordernumber = self.order?.number{
            return "Order #\(ordernumber)"
        }else{
            return "Order"
        }
    }
    
}

