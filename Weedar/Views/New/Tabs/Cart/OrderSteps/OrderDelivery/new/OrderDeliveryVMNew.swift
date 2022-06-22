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

class OrderDeliveryVMNew: ObservableObject {
    
    enum OrderType{
        case none
        case pickup
        case delivery
    }
    
    @Published var disableNavButton = false
    
    @Published var currentOrderType: OrderType = .none{
        didSet{
            validateButton()
        }
    }
    
    @Published var deliveryAvailable = false
    @Published var pickUpAvailable = false
    
    @Published var userName = ""{
        didSet{
            validation()
        }
    }
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
    
    @Published var showAlertError = false
    @Published var messageAlertError = ""
    
    private var oldZipCode = ""
    private var latitudeCoordinate: Double = 0
    private var longitudeCoordinate: Double = 0
    
    var descriptionText: String {
        switch currentOrderType {
        case .none:
            return "Enter your address or select 'Use my location'. Available options will be shown - delivery, pick up, or both. Then choose an option you want."
        case .pickup:
            return "Incorrectly entered address  may delay your order, so please double check for misprints. Do not enter specific dispatch instruction in any of address fields."
        case .delivery:
            return "Order will be ready in 15 minutes for pick up in the store. Budtender will ask you to show your ID and tell them your order number."
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
    
    func validation(){
        if userName.isEmpty{
            userNameTFState = .error
            userNameError = "Please enter full name."
        }else{
            userNameTFState = .success
            userNameError = ""
        }
        self.validationAddress()
    }
    
    private func validationAddress(){
        if !userAddress.isEmpty{
            checkPickupAvailable()
            if oldZipCode != zipCode{
                checkZipCode(zipCode: zipCode, validArea: { value in
                    if value{
                        self.addressError = ""
                        self.userAddressTFState = .success
                        self.deliveryAvailable = true
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
                let stores = json.arrayValue
                if stores.count > 0{
                    self.pickUpAvailable = true
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
    
}


extension OrderDeliveryVMNew{
    
    func saveDataCreateOrder(success: @escaping (OrderModel)->Void){
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
                self.showAlertError = true
                self.createOrderButtonState = .def
            }
        }
    }
    
    func makeOrder(success: @escaping (OrderModel)->Void) {
        //{ delivery = 0, pickUp = 1 }
        guard let user = userData else { return  }
        
        let params: Parameters = [
            "name": user.name,
            "phone": user.phone ?? "phone error",
            "addressLine1": userAddress,
            "zipCode": zipCode,
            "user": user.id,
            "city": " ",
            "addressLine2" : " ",
            "latitudeCoordinate": latitudeCoordinate,
            "longitudeCoordinate": longitudeCoordinate,
            "type": 0
        ]
        
        API.shared.request(rout: .getOrderById, method: .post, parameters: params, encoding: JSONEncoding.default) { result in
            switch result{
            case let .success(json):
                let order = OrderModel(json: json)
                success(order)
                self.createOrderButtonState = .def
            case let .failure(error):
                self.createOrderButtonState = .def
                self.messageAlertError = error.message
                self.showAlertError = true
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
    
    private func boolValue(data: Data) -> Bool? {
         return String(data: data, encoding: .utf8).flatMap(Bool.init)
     }
    
}


//Picker
extension OrderDeliveryVMNew{
    
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
}
