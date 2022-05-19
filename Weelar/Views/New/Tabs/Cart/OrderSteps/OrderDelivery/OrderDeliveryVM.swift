//
//  OrderDeliveryVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 10.03.2022.
//

import SwiftUI
import Amplitude
import Alamofire

class OrderDeliveryVM: ObservableObject {
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = true
    
    @Published var usernameTFState: TextFieldState = .def
    @Published var addressTFState: TextFieldState = .def

    @Published var disableNavButton = false
    
    @Published var addressErrorMessage = ""
    
    @Published var addressIsEditing = false
    
    @Published var userInfo = UserInfo()
    
    @Published var userData: UserModel?
    
    @Published var checkoutAlertShow: Bool = false
    
    @Published var errorMessage = ""
    
    @Published var name: String = ""
    
    @Published var validName = false
    
    @Published var needToLoadDoc = false
    
    @Published var showDocCenter = false

    @Published var cartProducts: [CartDetails] = []
    
    @Published var address: String = "" {
        didSet {
            GooglePlaceRepository.shared.searchLocation(address) { places in
                print(places)
                self.places = places
            }
        }
    }
    
    @Published var deliveryState: AvailabityDeliveryState = .def
    
    @Published var pickUpState: AvailabityDeliveryState = .def
    
    @Published var orderDetailsReview: OrderDetailsReview?
    
    @Published var lastName: String = ""
    @Published var lastAddress: String = ""
    
    @Published var isErrorShow: Bool = false {
        didSet {
            if isErrorShow {
                usernameTFState = .error
                addressTFState = .error
            } else {
                usernameTFState = .def
                addressTFState = .def
            }
        }
    }
    
    @Published var stepSuccess = false
    
    var placesCount = 0
    
    let ud = UserDefaultsService()
    
    @Published var places: Places? {
        didSet {
            self.placesCount = places?.predictions.count ?? 0
        }
    }
    
    var selectionPlace: Places.Prediction? {
        didSet {
            guard let placeID = places?.predictions.first?.placeID else { return }
            GooglePlaceRepository.shared.detailsLocation(placeID) { places in
              
                self.address = places.formattedAddress ?? ""
                self.userInfo.addressLine1 = places.addressLine1 ?? ""
                self.userInfo.zipCode = places.zipCode ?? ""
                self.userInfo.city = places.city ?? ""
                self.userInfo.latitudeCoordinate = places.location.lat
                self.userInfo.longitudeCoordinate = places.location.lng
                
                self.zipcodeAndNameValidation()
            }
        }
    }
    
    init(){
        getUserData()
    }
    
    func saveUserInfo() {
        saveAdressAndName(userId: userData?.id ?? 0,
                          username: name,
                          city: userInfo.city ?? "",
                          addressLine1: self.address,
                          addressLine2: userInfo.addressLine2,
                          latitudeCoordinate: userInfo.latitudeCoordinate,
                          longitudeCoordinate: userInfo.longitudeCoordinate,
                          zipCode: userInfo.zipCode ?? "")
       
        if lastName != name{
            if UserDefaults.standard.bool(forKey: "EnableTracking"){

            Amplitude.instance().logEvent("name_change")
            }
        }
        
        if lastAddress != address{
            if UserDefaults.standard.bool(forKey: "EnableTracking"){

            Amplitude.instance().logEvent("address_change")
            }
        }

    }
    
    func saveAdressAndName(userId: Int, username: String, city: String, addressLine1: String, addressLine2: String, latitudeCoordinate: Double, longitudeCoordinate: Double, zipCode: String){
       
        let url = Routs.user.rawValue.appending("/\(userId)")
        
        let params: Parameters = [
            "name" : username,
            "addresses" : [
                [
                "city" : city,
                "addressLine1" : addressLine1,
                "addressLine2" : addressLine2,
                "latitudeCoordinate" : latitudeCoordinate,
                "longitudeCoordinate" : longitudeCoordinate,
                "zipCode" : zipCode
                ]
            ]
        ]
        
        API.shared.request(endPoint: url, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(_):
                self.stepSuccess.toggle()
                print("Address sended")
                if UserDefaults.standard.bool(forKey: "EnableTracking"){

                Amplitude.instance().logEvent("address_change_success")
                }
            case let .failure(error):
                print("Error to send data \(error)")
                if UserDefaults.standard.bool(forKey: "EnableTracking"){

                Amplitude.instance().logEvent("address_change_fail", withEventProperties: ["error_type" : error.localizedDescription])
                }
                break
            }
        }
    }
    
    func getUserData() {
        API.shared.request(rout: .getCurrentUserInfo, method: .get) { result in
            switch result {
            case let .success(json):
                let userData = UserModel(json: json)
                self.userData = userData
                self.userInfo = UserInfo(name: userData.name,
                                         phone: userData.phone,
                                         city: userData.addresses.first?.city,
                                         addressLine1: userData.addresses.first?.addressLine1,
                                         addressLine2: userData.addresses.first?.addressLine2 ?? "",
                                         zipCode: userData.addresses.first?.zipCode,
                                         latitudeCoordinate: userData.addresses.first?.latitudeCoordinate ?? 0,
                                         longitudeCoordinate: userData.addresses.first?.longitudeCoordinate ?? 0)
               
                if let address =  userData.addresses.first?.addressLine1{
                    self.address = address
                    self.lastAddress = address
                    self.addressTFState = .success
                }else{
                }
                
                if  !userData.name.isEmpty {
                    self.name = userData.name
                    self.lastName = userData.name
                    self.usernameTFState = .success
                }
                
                self.zipcodeAndNameValidation()
            case let .failure(error):
                print("error to get user data \(error)")
            }
        }
    }
    
    
    func validateAddress(valid: @escaping (Bool) -> Void){
        if (userInfo.city ?? "").isEmpty{
            self.addressErrorMessage = "City is not set."
            valid(false)
        } else if (userInfo.zipCode ?? "").isEmpty{
            self.addressErrorMessage = "Zipcode is not set."
            valid(false)
        }else{
            errorMessage = ""
            valid(true)
        }
    }
    
    func composeOrder(name: String, sum: Double, finished: @escaping(Bool) -> Void) {
        userInfo.addressLine1 = address
        userInfo.sum = sum
        userInfo.totalSum = sum
        userInfo.name = name
        userInfo.phone = getUserPhone()
        userInfo.user = UserDefaultsService().get(fromKey: .user) as? Int ?? 0
        
        if userInfo.isCompleted() {
                finished(true)
            return
        }
        
        finished(false)
        return
    }
    
    func getUserPhone() -> String {
        return UserDefaultsService().get(fromKey: .phone) as? String ?? "Phone Number"
    }
    
    func validation() -> Bool{
        if name == ""{
            usernameTFState = .error
            self.buttonState = .def
            checkoutAlertShow.toggle()
            errorMessage = "Please enter full name."
            disableNavButton = false
            return false
        }else if address == ""{
            usernameTFState = .success
            disableNavButton = false
            return false
        }else{
            return true
        }
    }
    
    
    
    func zipcodeAndNameValidation(){
        if !name.isEmpty{
            self.usernameTFState = .success
            self.checkArea(area: self.userInfo.zipCode ?? "") { val in
                if !self.address.isEmpty{
                    if val{
                        self.addressErrorMessage = ""
                        self.validateAddress { valid in
                            if valid{
                                self.addressTFState = .success
                                self.deliveryState = .success
                                self.buttonIsDisabled = false
                            }else{
                                self.addressTFState = .error
                                self.deliveryState = .notFound
                                self.buttonIsDisabled = true
                            }
                        }
                    }else{
                        self.addressErrorMessage = "We do not deliver to this zip-code yet."
                        self.deliveryState = .notFound
                        self.buttonIsDisabled = true
                    }
                }
            }
        }
    }
    
    func makeOrder(userInfo: UserInfo, cartProducts: [CartDetails],  finished: @escaping(Bool, String) -> Void) {
       
        self.cartProducts = cartProducts
        
        let data = OrderRequestModel(userInfo: userInfo,
                                     cartProducts: cartProducts)
        

        OrderRepository().makeOrder(data: data
        ) {
            result in
            switch result {
                case .success(let orderResponse):
                self.orderDetailsReview =
                OrderDetailsReview(orderId: orderResponse.id,
                                   totalSum: orderResponse.totalSum,
                                   exciseTaxSum: orderResponse.exciseTaxSum,
                                   totalWeight:  self.totalGramWeight().formattedString(format: .percent),
                                   salesTaxSum: orderResponse.salesTaxSum,
                                   localTaxSum: orderResponse.cityTaxSum, discount: orderResponse.discount,
                                   taxSum: orderResponse.taxSum,
                                   state: orderResponse.state)
                self.saveUserInfo()
                
                print("order response \(orderResponse)")
                finished(true, "Success")
                
                case .failure(let error):
                    DispatchQueue.main.async {
                        finished(false, error.message)
                    }
            }
        }
    }
    
    //Get total gram in product
     func totalGramWeight() -> Double {
         var sum = 0.0
         
         for product in  cartProducts{
             sum += product.product.gramWeight
         }
         return sum
     }
    
    func checkArea(area: String,validArea: @escaping (Bool) -> Void) {
        let params = [
            "zipCode" : area
        ]
        
        API.shared.requestData(rout: .checkArea, method: .post, parameters: params,encoding: JSONEncoding.default) { result in
            switch result{
            case let .success(data):
                guard let value = self.boolValue(data: data) else { return }
                validArea(value)
                print("response area \(value)")
            case .failure(_):
                validArea(false)
            }
        }
    }
    
   private func boolValue(data: Data) -> Bool? {
        return String(data: data, encoding: .utf8).flatMap(Bool.init)
    }
}



