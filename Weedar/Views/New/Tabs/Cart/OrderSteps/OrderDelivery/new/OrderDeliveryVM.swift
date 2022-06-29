//
//  OrderDeliveryVMNew.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 21.06.2022.
//

import SwiftUI
import RealityKit
import SwiftyJSON
import Alamofire
import CoreLocation

class OrderDeliveryVM: ObservableObject {
    
    enum OrderType{
        case none
        case pickup
        case delivery
    }
    
    enum ActiveAlert {
        case error, location
    }
    
    @Published var showAlert = false
    @Published var activeAlert: ActiveAlert = .error
    
    
    @Published var disableNavButton = false
    
    @Published var currentOrderType: OrderType = .delivery{
        didSet{
            validateButton()
        }
    }
    
    @Published var deliveryAvailable = false
    @Published var pickUpAvailable = false
    
    @Published var userName = ""
    @Published var nameStrokeColor = Color.col_borders
    @Published var userNameTFState: TextFieldState = .def{
        didSet{
            validateButton()
        }
    }
    @Published var userNameError = ""
    
    
    @Published var userAddress = ""
    @Published var userAddressTFState: TextFieldState = .def{
        didSet{
            validateButton()
        }
    }
    
    @Published var addressStrokeColor = Color.col_borders
    @Published var addressError = ""
    @Published var zipCode = ""
    
    @Published var createOrderButtonState: ButtonState = .def
    @Published var createOrderButtonIsDisabled = false
    
    @Published var createdOrder: OrderResponseModel?
    
    
    @Published var userData: UserModel?{
        didSet{
            if let userData = userData {
                self.userName = userData.name
            }
            if let fullAddress = userData?.addresses.first?.addressLine1 {
                self.userAddress = fullAddress
            }
            if let zipCode = userData?.addresses.first?.zipCode{
                self.zipCode = zipCode
            }
            if let latitudeCoordinate = userData?.addresses.first?.latitudeCoordinate{
                self.latitudeCoordinate = latitudeCoordinate
            }
            if let longitudeCoordinate = userData?.addresses.first?.longitudeCoordinate{
                self.longitudeCoordinate = longitudeCoordinate
            }
                
        }
    }
    
    @Published var showAddressList = false
    @Published var addressListPlacesCount = 0
    @Published var addressListPlaces: Places?{
        didSet{
            if let count = addressListPlaces?.predictions.count{
                addressListPlacesCount = count
            }
        }
    }
    
    @Published var messageAlertError = ""
    
    
    @Published var locationIsLoading = false
    
    private var oldZipCode = ""
    private var latitudeCoordinate: Double = 0
    private var longitudeCoordinate: Double = 0
    
    var descriptionText: String {
        switch currentOrderType {
        case .none:
            return "Enter your address or select 'Use my current location'. Available options will be shown - delivery, pick up, or both. Then choose an option you want."
        case .pickup:
            return "Order will be ready in 15 minutes for pick up in the store. Budtender will ask you to show your ID and tell them your order number."
        case .delivery:
            return "Incorrectly entered address  may delay your order, so please double check for misprints. Do not enter specific dispatch instruction in any of address fields."
        }
    }
    
    
    func getGoogleAddressPrompt(addressText: String){
        GooglePlaceRepository.shared.searchLocation(addressText) { places in
            self.addressListPlaces = places
        }
    }
    
    func tapToGoogleAddress(placeID: String){
        GooglePlaceRepository.shared.detailsLocation(placeID) { place in
            if let fullAddress = place.formattedAddress{
                self.userAddress = fullAddress
            }
            if let zipCode = place.zipCode{
                self.zipCode = zipCode
            }
            self.latitudeCoordinate = place.location.lat
            self.longitudeCoordinate = place.location.lng
            
            self.validation()
        }
    }
    
    func validation(appear: Bool = false){
        if userName.isEmpty{
            if !appear{
                userNameTFState = .error
                userNameError = "Please enter Full name."
                createOrderButtonIsDisabled = true
            }
        }else{
            userNameTFState = .success
            userNameError = ""
            createOrderButtonIsDisabled = false
        }
        validateButton()
        self.validationAddress()
    }
    
    private func validationAddress(){
        if !userAddress.isEmpty{
            if oldZipCode != zipCode{
                checkZipCode(zipCode: zipCode, validArea: { value in
                    if value{
                        self.addressError = ""
                        self.userAddressTFState = .success
                        self.deliveryAvailable = true
                        self.checkPickupAvailable()
                    }else{
                        self.addressError = "We do not deliver to this zip-code yet."
                        self.userAddressTFState = .error
                    }
                })
            }
        }
    }
    
    private func validateButton(){
        if userNameTFState == .success, userAddressTFState == .success, currentOrderType != .none{
            createOrderButtonIsDisabled = false
        }else{
            createOrderButtonIsDisabled = true
        }
    }
    
    
   private func checkPickupAvailable(){
        API.shared.request(rout: .getAllStores, method: .get) { result in
            switch result{
            case let .success(json):
                let stores = json.arrayValue.map({StoreModel(json: $0)})
                var availableStores: [StoreModel] = []
                for store in stores{
                    if LocationManager().checkDistance(coord1: CLLocation(latitude: store.latitudeCoordinate,
                                                                          longitude: store.longitudeCoordinate),
                                                       coord2: CLLocation(latitude: self.latitudeCoordinate,
                                                                          longitude: self.longitudeCoordinate)) < 20{
                        availableStores.append(store)
                    }
                }
                if availableStores.count > 0{
                    self.pickUpAvailable = true
                }else{
                    self.pickUpAvailable = false
                }
            case let .failure(error):
                self.pickUpAvailable = false
            }
        }
    }
    
    
    func needToUploadDocuments() -> Bool{
        guard let userData = userData else {
            return true
        }
        if userData.passportPhotoLink.isEmpty{
            return true
        }else{
            return false
        }
    }
    
    func getCreatedOrder(order: OrderResponseModel?) -> OrderDetailsReview {
        guard let createdOrder = order else {
            return OrderDetailsReview(orderId: 0,
                                      totalSum: 0,
                                      exciseTaxSum: 0,
                                      salesTaxSum: 0,
                                      localTaxSum: 0,
                                      taxSum: 0,
                                      sum: 0,
                                      state: 0,
                                      fullAdress: "",
                                      username: "",
                                      phone: "",
                                      partnerPhone: "",
                                      partnerName: "",
                                      partnerAdress: "",
            orderNumber: "")
        }
        
        
        return OrderDetailsReview(orderId: createdOrder.id, totalSum: createdOrder.totalSum, exciseTaxSum: createdOrder.exciseTaxSum, totalWeight: createdOrder.gramWeight.formattedString(format: .gramm),salesTaxSum: createdOrder.salesTaxSum, localTaxSum: createdOrder.taxSum,discount: createdOrder.discount , taxSum: createdOrder.taxSum, sum: createdOrder.sum, state: createdOrder.state,fullAdress: createdOrder.addressLine1,username: createdOrder.name,phone: createdOrder.phone,partnerPhone: createdOrder.partner.phone, partnerName: createdOrder.partner.name, partnerAdress: createdOrder.partner.address,orderNumber: createdOrder.number)
    }
    
    func tapToAddressField() {
        if !userAddress.isEmpty{
            deliveryAvailable = false
            pickUpAvailable = false
            currentOrderType = .delivery
            userAddress = ""
            zipCode = ""
            addressError = ""
            userAddressTFState = .def
            locationIsLoading = false
        }
    }
}


extension OrderDeliveryVM{
    
    func saveDataCreateOrder(success: @escaping (OrderResponseModel)->Void){
        guard let id = userData?.id else { return }
        
        let url = Routs.user.rawValue.appending("/\(id)")
        
        let params: Parameters = [
            "name" : userName,
            "addresses" : [
                [
                    "city": " ",
                    "addressLine1" : userAddress,
                    "addressLine2" : " ",
                    "latitudeCoordinate" : latitudeCoordinate,
                    "longitudeCoordinate" : longitudeCoordinate,
                    "zipCode" : zipCode
                ]
            ]
        ]
        
        API.shared.request(endPoint: url, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(_):
                print("Save user info")
                
                self.makeOrder { order in
                    success(order)
                }
            case let .failure(error):
                self.messageAlertError = error.message
                self.activeAlert = .error
                self.showAlert = true
                self.createOrderButtonState = .def
                self.disableNavButton = false
            }
        }
    }
    
    func makeOrder(success: @escaping (OrderResponseModel)->Void) {
        let params: Parameters = [
            "name": userName,
            "addressLine1": userAddress,
            "zipCode": zipCode,
            "city": " ",
            "latitudeCoordinate": latitudeCoordinate,
            "longitudeCoordinate": longitudeCoordinate,
            "type": 0
        ]
        
        API.shared.request(rout: .getOrderById, method: .post, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case let .success(json):
                let order = OrderResponseModel(json: json)
                success(order)
                self.createOrderButtonState = .def
                self.disableNavButton = false
                AnalyticsManager.instance.event(key: .review_order_success)
            case let .failure(error):
                self.createOrderButtonState = .def
                self.activeAlert = .error
                self.messageAlertError = error.message
                self.showAlert = true
                self.disableNavButton = false
                AnalyticsManager.instance.event(key: .order_creation_fail,
                                                properties: [.order_creation_fail : error.message])
            }
        }
    }
    func checkZipCode(zipCode: String, validArea: @escaping (Bool) -> Void) {
        let params = [
            "zipCode" : zipCode
        ]
        
        API.shared.requestData(rout: .checkArea, method: .post, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case let .success(data):
                guard let value = self.boolValue(data: data) else { return }
                validArea(value)
            case .failure(_):
                validArea(false)
            }
        }
    }
    
    func saveUserData(finish: @escaping ()->Void){
        guard let id = userData?.id else { return }
        
        let url = Routs.user.rawValue.appending("/\(id)")
        
        if let user = userData{
            if user.name != userName {
                AnalyticsManager.instance.event(key: .name_change)
            }
            if userAddress != userAddress{
                AnalyticsManager.instance.event(key: .address_change_success)
            }
        }
            
        let params: Parameters = [
            "name" : userName,
            "addresses" : [
                [
                    "city": " ",
                    "addressLine1" : userAddress,
                    "addressLine2" : " ",
                    "latitudeCoordinate" : latitudeCoordinate,
                    "longitudeCoordinate" : longitudeCoordinate,
                    "zipCode" : zipCode
                ]
            ]
        ]
        
        API.shared.request(endPoint: url, method: .put, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case .success(_):
                print("Save user info")
                finish()
            case let .failure(error):
                self.activeAlert = .error
                self.messageAlertError = error.message
                self.showAlert = true
                self.createOrderButtonState = .def
                self.disableNavButton = false
                AnalyticsManager.instance.event(key: .address_change_fail, properties: [.error_type : error.message])
            }
        }
    }
    
    private func boolValue(data: Data) -> Bool? {
         return String(data: data, encoding: .utf8).flatMap(Bool.init)
     }
}


//Picker
extension OrderDeliveryVM{
    
    var pickerDeliveryTextColor: Color{
        switch currentOrderType {
        case .none:
            if deliveryAvailable{
                return Color.col_text_main
            }else{
                return Color.col_text_second
            }
        case .pickup:
            if deliveryAvailable{
                return Color.col_text_main
            }else{
                return Color.col_text_second
            }
        case .delivery:
            return Color.col_text_white
        }
    }
    
    var pickerPickUpTextColor: Color{
        switch currentOrderType {
        case .none:
            if pickUpAvailable{
                return Color.col_text_main
            }else{
                return Color.col_text_second
            }
        case .pickup:
            return Color.col_text_white
        case .delivery:
            if pickUpAvailable{
                return Color.col_text_main
            }else{
                return Color.col_text_second
            }
        }
    }
    
    var pickerSelectorBackgroudColor: Color{
        switch currentOrderType {
        case .none:
            return Color.clear
        case .pickup:
            return Color.col_black
        case .delivery:
            return Color.col_black
        }
    }
    
    var pickerSelectoreCurrentXLocation: CGFloat{
        switch currentOrderType {
        case .none:
            return (UIScreen.main.bounds.width / 2 - 24) / 2
        case .pickup:
            return (UIScreen.main.bounds.width / 2 - 24)
        case .delivery:
            return 0
        }
    }
    
    var pickerSelectoreCornerShape: UIRectCorner{
        switch currentOrderType {
        case .none:
            return [.allCorners]
        case .pickup:
            return [.topRight, .bottomRight]
        case .delivery:
            return [.topLeft, .bottomLeft]
        }
    }
    
    var infoText: String{
        switch currentOrderType{
        case.none:
            return ""
        case .pickup:
            return "Our budtender will ask you to show your ID \nto verify your identity and age"
        case .delivery:
            return "Our courier will ask you to show your ID \nto verify your identity and age"
        }
    }
}
