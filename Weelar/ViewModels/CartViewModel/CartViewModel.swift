//
//  CartViewModel.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 10.08.2021.
//

import Combine
import SwiftUI
import Foundation
import Amplitude

struct OrderDetailsReview {
    var orderId: Int
    var totalSum: Double
    var exciseTaxSum: Double
    var totalWeight: String?
    var salesTaxSum: Double
    var localTaxSum: Double
    var taxSum: Double
    var state: Int
}

struct CartProduct: Identifiable, Hashable, Codable {
    var id: Int
    var item: Product
    var quantity: Int
    var imageLink: String
    
    var totalProductsGramWeight: Double {
        return Double(quantity) * item.grammWeightDouble()
    }
    
    var totalProductsPrice: Double {
        return Double(quantity) * item.price
    }
    
    var isConcentrated: Bool {
        return !(["flower", "seeds", "preroll", "plants"].contains(item.type.name.lowercased()))
    }
    
    mutating func changeQuantity(id: Int, _ num: Int) {
        if (self.id == id){
            self.quantity += num
        }
    }
}

struct UserInfo {
    var name: String?
    var phone: String?
    var city: String?
    var addressLine1: String?
    var addressLine2: String = "none"
    var zipCode: String?
    var user: Int?
    var sum: Double?
    var deliverySum: Double = 10.0 // default
    var totalSum: Double?
    var latitudeCoordinate: Double = 1.0
    var longitudeCoordinate: Double = 1.0
    var wholesalePrice: Double = 1.0
    
    //TODO: Improve
    func isCompleted() -> Bool {
        guard let name = self.name else {
            print("Name field is not set!")
            return false
        }
        
        guard let phone = self.phone else {
            print("Phone field is not set!")
            return false
        }
        
        guard let city = self.city else {
            print("City field is not set!")
            return false
        }
        
        guard let addressLine1 = self.addressLine1 else {
            print("City field is not set!")
            return false
        }
        
        guard let zipCode = self.zipCode else {
            print("ZipCode field is not set!")
            return false
        }
        
        guard user != nil else {
            print("UserID field is not set!")
            return false
        }
        
        guard sum != nil else {
            print("Sum field is not set!")
            return false
        }
        
        guard totalSum != nil else {
            print("TotalSum field is not set!")
            return false
        }
        
        for data in [name, phone, city, addressLine1, zipCode] {
            if data.isEmpty {
                return false
            }
        }
        
        return true
    }
}

final class CartViewModel: ObservableObject {
    // MARK: - Properties
    @Published var productsInCart: [CartProduct] = []
    @Published var userInfo = UserInfo()
    @Published var orderDetailsReview: OrderDetailsReview? //= OrderDetailsReview(orderId: 2, totalSum: 2, exciseTaxSum: 2, salesTaxSum: 2, localTaxSum: 2, taxSum: 2)
    @Published var name: String = ""
    @Published var isDeliveryDetailsShow: Bool = false
    
    @Published var places: Places? {
        didSet {
            placesCount = places?.predictions.count ?? 0
        }
    }
    
    @Published var address: String = "" {
        didSet {
            GooglePlaceRepository.shared.searchLocation(address) { places in
                self.places = places
            }
        }
    }
    
    @Published var showSuccessView  = false
    
    private var userId: Int = 0
    
    var flowInProgress = false
    
    @Published var dailyConcentratedAllowance: Double = 8.0
    
    @Published var dailyNonConcentratedAllowance: Double = 28.5
    
    @Published var deliveryState: AvailabityDeliveryState = .def
    @Published var pickUpState: AvailabityDeliveryState = .def
    @Published var buttonState: ButtonState = .def
    @Published var showOrderReviewView = false
    @Published var buttonIsDisabled = false
    
    var zipCodes: [DeliveryZipCodesModel] = []
    
    private var cancelables = [AnyCancellable]()
   

    
    // MARK: - Initialization
    init(){
        self.userId = UserDefaultsService().get(fromKey: .user) as? Int ?? 0
        
        self.loadCart()

    }
    
    var placesCount = 0
    
    var selectionPlace: Places.Prediction? {
        didSet {
            selectionPlace = nil
            guard let placeID = places?.predictions.first?.placeID else { return }
            GooglePlaceRepository.shared.detailsLocation(placeID) { places in
                self.address = places.formattedAddress ?? ""
                self.userInfo.addressLine1 = places.addressLine1 ?? ""
                self.userInfo.zipCode = places.zipCode ?? ""
                self.userInfo.city = places.city ?? ""
                self.userInfo.latitudeCoordinate = places.location.lat
                self.userInfo.longitudeCoordinate = places.location.lng
                
                self.zipcodeValidation(zipCode: places.zipCode ?? "" )
            }
        }
    }
    
    func onAppear() {
       UserDefaults.standard
            .publisher(.userHasRecPhoto)
            .receive(on: RunLoop.main)
            .sink { [weak self] userHasRecPhoto in
                if userHasRecPhoto {
                    self?.dailyConcentratedAllowance = 64.0
                    self?.dailyNonConcentratedAllowance = 226.7
                } else {
                    self?.dailyConcentratedAllowance = 8
                    self?.dailyNonConcentratedAllowance = 28.5
                }
            }
            .store(in: &cancelables)
    }
    
    func onDisappear() {
        cancelables = []
    }
    
    @Published var addressIsEditing = false
    
    func updateAddress(){
        self.address = ""
        self.selectionPlace = nil
        self.places = nil
    }
    
    func zipcodeValidation(zipCode: String){
        for code in zipCodes {
            let zip = code.zipCode.components(separatedBy: " ")[1]
            if zipCode == zip{
                deliveryState = .success
                buttonIsDisabled = false
                break
            }else{
                deliveryState = .notFound
                buttonIsDisabled = true
            }
        }
    }

    func saveUserInfo() {
        
        UserDefaultsService().set(value: self.address, forKey: .userAddress)
        UserDefaultsService().set(value: userInfo.zipCode, forKey: .zipCode)
        UserDefaultsService().set(value: userInfo.city, forKey: .city)
        UserDefaultsService().set(value: name, forKey: .userFullName)
        UserDefaultsService().set(value: userInfo.addressLine1, forKey: .addressLine1)
        
        UserDefaultsService().set(value: userInfo.latitudeCoordinate, forKey: .latitudeCoordinate)
        UserDefaultsService().set(value: userInfo.longitudeCoordinate, forKey: .longitudeCoordinate)
        
        ampUserPropertyNameAndAddress()
    }

    // User's name and address are set in Amplitude Analytics
    private func ampUserPropertyNameAndAddress() {
        Amplitude.setAmpUserProperty(key: "name", value: self.name as NSObject)
        Amplitude.setAmpUserProperty(key: "address", value: self.address as NSObject)
    }

    // User's purchased orders number is increased by 1 and set in Amplitude Analytics
    func ampUserPropertyOrdersNumber() {
        Amplitude.addAmpUserProperty(key: "orders_purchased", value: NSNumber(value: 1))
    }
    
    // User's purchased products number is increased by count of products in cart and set in Amplitude Analytics
    func ampUserPropertyProductsNumber(productsCount: NSNumber) {
        Amplitude.addAmpUserProperty(key: "products_purchased", value: productsCount)
    }

//    func fetchFromDefaults() {
//        self.userInfo.name = UserDefaultsService().get(fromKey: .userFullName) as? String ?? ""
//        self.userInfo.addressLine1 = UserDefaultsService().get(fromKey: .addressLine1) as? String ?? ""
//        self.userInfo.zipCode = UserDefaultsService().get(fromKey: .zipCode) as? String ?? ""
//        self.userInfo.city = UserDefaultsService().get(fromKey: .city) as? String ?? ""
//        self.userInfo.latitudeCoordinate = UserDefaultsService().get(fromKey: .latitudeCoordinate) as? Double ?? 0
//        self.userInfo.longitudeCoordinate = UserDefaultsService().get(fromKey: .longitudeCoordinate) as? Double ?? 0
//        self.name = userInfo.name ?? ""
//        self.address = UserDefaultsService().get(fromKey: .userAddress) as? String ?? ""
//    }
    
    func getOrderDetails (_ orderId: Int) {
        OrderRepository.shared.getOrderDetails(orderId: orderId) { result in
            switch result {
                case .success(let item):
                    var cartProduct: [CartProduct] = []
                    item.forEach { details in
                        cartProduct.append(CartProduct(id: orderId, item: details.product, quantity: details.quantity,imageLink: details.product.imageLink))
                    }
                    self.productsInCart = cartProduct
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func totalProductsQuantity() -> Int {
        return productsInCart.map({ $0.quantity }).reduce(0, +)
    }
    
    private func getProduct(id: Int) -> Product? {
        let product = ProductsViewModel.shared.products.first { $0.id == id }
        return product
    }
    
    func containsProduct(id: Int) -> Bool {
        return getCartProduct(id: id) != nil
    }
    
    func getCartProduct(id: Int) -> CartProduct? {
        let product = productsInCart.first { $0.id == id }
        return product
    }
    
    func getUserPhone() -> String {
        return UserDefaultsService().get(fromKey: .phone) as? String ?? "Phone Number"
    }
    
    @discardableResult
    func changeQuantityOfProduct(id: Int, quantity: Int) -> Int{
        let index = productsInCart.firstIndex { $0.id ==  id }
        
        guard let indexConfirmed = index else {
            print("Index not found")
            return 0
        }
        
        productsInCart[indexConfirmed].changeQuantity(id: id, quantity)
        
        if (productsInCart[indexConfirmed].quantity <= 0) {
            productsInCart.remove(at: indexConfirmed)
            saveCart()
            return 0
        }
        saveCart()
        return productsInCart[indexConfirmed].quantity
    }
    
    func totalGramWeight() -> Double {
        var sum = 0.0
        
        for product in productsInCart {
            sum += product.totalProductsGramWeight
        }
        return sum
    }
    
    func totalPrice() -> Double {
        var sum = 0.0
        
        for product in productsInCart {
            sum += product.totalProductsPrice
        }
        return sum
    }
    // Weight for concentraited or nonconcentraied
    func totalGramWeight(concentrated: Bool) -> Double {
        var sum = 0.0
        
        for product in productsInCart {
            if concentrated  == product.isConcentrated {
                sum += product.totalProductsGramWeight
            }
        }
        return sum
    }
    
    
    
    func fetchUserDailyAllowance() {
        let userId = UserDefaultsService().get(fromKey: .user) as! Int
        
        UserRepository
            .shared
            .getUserInfo(userId: userId) { result in
                switch result {
                    case .success(let userInfo):
                        print(userInfo)
                        //UserDefaultsService().set(value: false, forKey: .userHasRecPhoto)
                        UserDefaults.standard[.userHasRecPhoto] = false

                        if let rec = userInfo.physicianRecPhotoLink {
                            if !rec.isEmpty {
                                UserDefaults.standard[.userHasRecPhoto] = true
                               // UserDefaultsService().set(value: true, forKey: .userHasRecPhoto)
                            }
                        }
                    case .failure(let error):
                        Logger.log(message: error.localizedDescription, event: .error)
                }
            }
    }
    
    func makeOrder(userInfo: UserInfo, cartProducts: [CartProduct],  finished: @escaping(Bool, String) -> Void) {
        let data = OrderRequestModel(userInfo: userInfo, cartProducts: cartProducts)
        OrderRepository().makeOrder(data: data
        ) {
            result in
            switch result {
                case .success(let orderResponse):
                    print(orderResponse) //del
                    DispatchQueue.main.async {
                        self.orderDetailsReview =
                        OrderDetailsReview(orderId: orderResponse.id,
                                           totalSum: orderResponse.totalSum,
                                           exciseTaxSum: orderResponse.exciseTaxSum,
                                           salesTaxSum: orderResponse.salesTaxSum,
                                           localTaxSum: orderResponse.cityTaxSum,
                                           taxSum: orderResponse.taxSum,
                                           state: orderResponse.state)
                        finished(true, "Success")
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        finished(false, error.message)
                    }
            }
        }
    }
    
    func confirmOrder(finished: @escaping(Bool) -> Void) {
        guard let id = orderDetailsReview?.orderId else {
            return
        }
        
        OrderRepository().confirmOrder(id: id) {
            result in
            switch result {
                case .success(let orderConfirmStatus):
                    _ = orderConfirmStatus
                    DispatchQueue.main.async {
                        finished(true)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        finished(false)
                    }
            }
        }
    }
    
    func composeOrder(name: String, finished: @escaping(Bool) -> Void) {
        
        userInfo.addressLine1 = address
        userInfo.sum = totalPrice()
        userInfo.totalSum = totalPrice()
        userInfo.name = name
        userInfo.phone = getUserPhone()
        userInfo.user = userId
        
        if userInfo.isCompleted() {
            finished(true)
            return
        }
        finished(false)
        return
    }
    
    @discardableResult
    func addToCart(id: Int, quantity: Int = 1) -> Bool {
        if productsInCart.contains(where: {$0.id == id} ) {
            changeQuantityOfProduct(id: id, quantity: quantity)
            saveCart()
            successHapticFeedback()
            return true
        }
        
        
        guard let product = getProduct(id: id) else {
            print("AR Prduct\(id) not found in UI")
            return false
        }
        productsInCart.append(CartProduct(id: id, item: product, quantity: quantity,imageLink: product.imageLink))
        saveCart()
        successHapticFeedback()
        return true
    }
    
    private func saveCart() {
        //        guard !productsInCart.isEmpty else { return } //save empty cart
        UserDefaults.standard.set(Date(), forKey: "LastAddToCart\(userId)")
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(productsInCart)
            UserDefaults.standard.set(data, forKey: "Card\(userId)")
        } catch {
            print("Unable to Encode Array of Card (\(error))")
        }
    }
    
    private func loadCart() {
        if let date = UserDefaults.standard.object(forKey: "LastAddToCart\(userId)") as? Date {
            let nextDay = date.addingTimeInterval(60 * 60 * 24)
            if nextDay < Date() {
                UserDefaults.standard.removeObject(forKey: "Card\(userId)")
                return
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "Card\(userId)") {
            do {
                let decoder = JSONDecoder()
                productsInCart = try decoder.decode([CartProduct].self, from: data)
                
            } catch {
                print("Unable to Decode Cart (\(error))")
            }
        }
    }
    
    func clearCart() {
        UserDefaults.standard.removeObject(forKey: "Card\(userId)")
        self.productsInCart = []
        //        self.userInfo = UserInfo() //clear later
        self.orderDetailsReview = nil
    }
    
    func successHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}
