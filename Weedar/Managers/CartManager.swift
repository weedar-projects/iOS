//
//  CartManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 16.03.2022.
//

import SwiftUI
 
import SwiftyJSON
import Alamofire

class CartManager: ObservableObject {
    
    
    @Published var cartData: CartModel?{
        didSet{
            if let productsInCart = cartData?.cartDetails{
                productsCount = 0
                for product in productsInCart {
                    productsCount += product.quantity
                }
            }
        }
    }
    @Published var productsCount = 0
    
    @Published var showCartManagerError = false
    @Published var messageCartManagerError = ""
    
    @Published var userData: UserModel?
    
    enum CartPrdouctQuantity{
        case add
        case reduce
        case removeAll
        case custom(Int)
    }
    
    init() {
        getCart()
    }
    
    func successHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    func getCart(){
        API.shared.request(rout: .cart, method: .get) { result in
            switch result{
            case .success(let json):
                let cart = CartModel(json: json)
                self.cartData = cart
            case .failure(let error):
                print("Error loading cart \(error)")
//                self.messageCartManagerError = error.message
//                self.showCartManagerError = true
            }
        }
    }
    
    func productQuantityInCart(productId: Int, quantity: CartPrdouctQuantity, success: @escaping ()->Void = {}){
        guard let cartData = cartData else {
            print("Error Cart is Empty")
            return
        }
        
        var currentQuantity: Int {
            var quantity = 0
            for product in cartData.cartDetails{
                if product.product.id == productId{
                    quantity = product.quantity
                }
            }
            return quantity
        }
        
        var newQuantity: Int{
            switch quantity {
            case .add:
                return currentQuantity + 1
            case .reduce:
                return currentQuantity - 1
            case .removeAll:
                return 0
            case .custom(let quantity):
                return currentQuantity + quantity
            }
        }
       
        
        let parmas = [
            "product": productId,
            "quantity": newQuantity
        ]
        
        API.shared.request(rout: .cart, method: .put, parameters: parmas, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(let json):
                let cart = CartModel(json: json)
                self.cartData = cart
                success()
            case .failure(let error):
                print("Error to change quantity cart \(error)")
                self.messageCartManagerError = error.message
                self.showCartManagerError = true
            }
        }
    }
    
    func clearAllProductCart(){
        API.shared.request(rout: .cart, method: .delete) { result in
            switch result{
            case .success(let json):
                let cart = CartModel(json: json)
                self.cartData = cart
                AnalyticsManager.instance.event(key: .clear_cart)
            case .failure(let error):
                print("Error to clear cart \(error)")
                self.messageCartManagerError = error.message
                self.showCartManagerError = true
            }
        }
    }
    
    func removePromocode() {
        let params = [
            "promoCode" : ""
        ]
        API.shared.request(rout: .cart, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(let json):
                let data = CartModel(json: json)
                self.cartData = data
                
            case .failure(let error):
                print("\(error.message)")
                self.messageCartManagerError = error.message
                self.showCartManagerError = true
            }
        }
    }
}


struct DiscountModel: Codable, Identifiable{
    enum DiscountMeasure: Codable{
        case percent
        case dollar
    }

    enum DiscountType: Codable{
        case promoCode
        case firstOrder
      }

    var id: Int
    var type: DiscountType
    var value: Double
    var measure: DiscountMeasure
    
    init(json: JSON) {
        self.value = json["value"].doubleValue
        self.id = json["id"].intValue
        self.type = {
            let typeCode = json["type"].doubleValue
            switch typeCode{
            case 0:
                return .promoCode
            case 1:
                return .firstOrder
            default:
                return .promoCode
            }
        }()
        self.measure = {
            let typeCode = json["measure"].doubleValue
            switch typeCode{
            case 0:
                return .percent
            case 1:
                return .dollar
            default:
                return .dollar
            }
        }()
    }
}

struct CartModel{
    
    var sum: Double
    var deliverySum: Double
    var totalSum: Double
    var totalWeight: Double
    var productsSum: Double
    var discount: DiscountModel
    var priceCorresponds: Bool
    var cartDetails: [CartDetails]
    
    init(json: JSON) {
        self.sum = json["sum"].doubleValue
        self.deliverySum = json["deliverySum"].doubleValue
        self.totalSum = json["totalSum"].doubleValue
        self.totalWeight = json["totalWeight"].doubleValue
        self.productsSum = json["productsSum"].doubleValue
        self.discount = DiscountModel(json: json["discount"])
        self.cartDetails = json["cartDetails"].arrayValue.map({CartDetails(json: $0)})
        self.priceCorresponds = json["priceCorresponds"].boolValue
    }
}

struct CartDetails: Hashable{
    var quantity: Int
    var product: ProductModel
    init(json: JSON){
        self.quantity = json["quantity"].intValue
        self.product = ProductModel(json: json["product"])
    }
}


