//
//  OrderDeliveryVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 10.03.2022.
//

import SwiftUI

class OrderDeliveryVM: ObservableObject {
    
    @Published var buttonState: ButtonState = .def
    @Published var buttonIsDisabled = false
    
    @Published var username: String = ""
    @Published var usernameTFState: TextFieldState = .def
    @Published var addressTFState: TextFieldState = .def

    @Published var addressIsEditing = false
    @Published var userInfo = UserInfo()
    
    @Published var address: String = "" {
        didSet {
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
    
    let ud = UserDefaultsService()
    
    let zipCodesRepo = DeliveryZipCodesRepository()
    
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
    
    init() {
        self.zipCodesRepo.getZipCodes { res in
            switch res{
            case let .success(zipCodes):
                self.zipCodes = zipCodes
            case let .failure(error):
                print(error.message)
            }
        }
    }
    
    func saveUserDeliveryAddress(userInfo: UserInfo){
        if validation(){
            self.ud.set(value: self.address, forKey: .userAddress)
            self.ud.set(value: userInfo.zipCode, forKey: .zipCode)
            self.ud.set(value: userInfo.city, forKey: .city)
            self.ud.set(value: username, forKey: .userFullName)
            self.ud.set(value: userInfo.latitudeCoordinate, forKey: .latitudeCoordinate)
            self.ud.set(value: userInfo.longitudeCoordinate, forKey: .longitudeCoordinate)
            self.stepSuccess.toggle()
        }
    }
    
    private func validation() -> Bool{
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
        for code in zipCodes {
            let zip = code.zipCode.components(separatedBy: " ")[1]
            print("\(zip) == \(zipCode)")
            if zipCode == zip{
                deliveryState = .success
                buttonIsDisabled = false
                print("aviable")
                break
            }else{
                deliveryState = .notFound
                buttonIsDisabled = true
                print("disable")
            }
        }
    }
}

