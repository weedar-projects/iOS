//
//  DeliveryDetailsVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.03.2022.
//

import SwiftUI
import Alamofire
 

class DeliveryDetailsVM: ObservableObject {
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = false
    
    @Published var username: String = ""{
        didSet{
            print("usernamename: \(username)")
        }
    }
    
    @Published var usernameTFState: TextFieldState = .def
    @Published var addressTFState: TextFieldState = .def

    @Published var addressIsEditing = false
    
    @Published var userInfo = UserInfo()
    
    @Published var address: String = "" {
        didSet {
            print("addressaddress: \(address)")
            GooglePlaceRepository.shared.searchLocation(address) { places in
                self.places = places
            }
        }
    }
    
    @Published var deliveryState: AvailabityDeliveryState = .def
    
    @Published var pickUpState: AvailabityDeliveryState = .def
    
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
    var addressFailQty = 0
    
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
                
                self.zipcodeValidation(zipCode: places.zipCode ?? "")
            }
        }
    }
    
    var zipCodes: [DeliveryZipCodesModel] = []
    
    func validation() -> Bool{
        if username == ""{
            usernameTFState = .error
            return false
        }else if address == ""{
            return false
        }else{
            return true
        }
        self.buttonState = .def
    }
    

    
    private func zipcodeValidation(zipCode: String){
        
        self.checkArea(area: zipCode) { val in
            print("AREA VAL = \(val)")
            if val{
                self.deliveryState = .success
                self.buttonIsDisabled = false
            }else{
                self.deliveryState = .notFound
                self.buttonIsDisabled = true
            }
        }
    }
    
    func addAdressAndName(userId: Int ,city: String, addressLine1: String, addressLine2: String, latitudeCoordinate: Double, longitudeCoordinate: Double, zipCode: String){
       
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
            case let .failure(error):
                print("Error to send data \(error)")
                
                break
            }
        }
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
                self.addressFailQty += 1
                AnalyticsManager.instance.event(key: .address_signup_fail, properties: [.adress_fail_qty : self.addressFailQty])
            }
        }
    }
    
   private func boolValue(data: Data) -> Bool? {
        return String(data: data, encoding: .utf8).flatMap(Bool.init)
    }
    
}
