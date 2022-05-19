//
//  CartManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 16.03.2022.
//

import SwiftUI
import Amplitude
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
    
    func getUserData(needToShowDiscount: @escaping (Bool) -> Void){
        API.shared.request(rout: .getCurrentUserInfo) { result in
            switch result{
            case let .success(json):
                let user = UserModel(json: json)
                self.userData = user
            case let .failure(error):
                print("error to load user data: \(error)")
            }
        }
    }
    
    func getCart(){
        API.shared.request(rout: .cart, method: .get) { result in
            switch result{
            case .success(let json):
                let cart = CartModel(json: json)
                self.cartData = cart
            case .failure(let error):
                print("Error loading cart \(error)")
            }
        }
    }
    
    func productQuantityInCart(productId: Int, quantity: CartPrdouctQuantity){
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
            case .failure(let error):
                print("Error to change quantity cart \(error)")
            }
        }
    }
    
    func clearAllProductCart(){
        API.shared.request(rout: .cart, method: .delete) { result in
            switch result{
            case .success(let json):
                let cart = CartModel(json: json)
                self.cartData = cart
                if UserDefaults.standard.bool(forKey: "EnableTracking"){
                    Amplitude.instance().logEvent("clear_cart")
                }
            case .failure(let error):
                print("Error to clear cart \(error)")
            }
        }
    }
}



struct CartModel{
    var sum: Double
    var deliverySum: Double
    var totalSum: Double
    var totalWeight: Double
    var discount: Double
    var cartDetails: [CartDetails]
    
    init(json: JSON) {
        self.sum = json["sum"].doubleValue
        self.deliverySum = json["deliverySum"].doubleValue
        self.totalSum = json["totalSum"].doubleValue
        self.totalWeight = json["totalWeight"].doubleValue
        self.discount = json["discount"].doubleValue
        self.cartDetails = json["cartDetails"].arrayValue.map({CartDetails(json: $0)})
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


