//
//  SessionManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 21.03.2022.
//

import SwiftUI
import SwiftyJSON

class SessionManager: ObservableObject {
    
    @Published var userIsLogged: Bool
    @Published var needToFillUserData: Bool
    
    @Published var user: UserModel?
    
    let udf = UserDefaultsService()
        
    init() {
        userIsLogged = udf.get(fromKey: .userIsLogged) as? Bool ?? false
        needToFillUserData = udf.get(fromKey: .needToFillUserData) as? Bool ?? true
        userData(withUpdate: true)
        print("dafsdf")
    }
    
    func userData(withUpdate: Bool = false, userModel: @escaping (UserModel) -> Void = {_ in}){
        if withUpdate{
        API.shared.request(rout: .getCurrentUserInfo) { result in
            switch result{
            case let .success(json):
                let user = UserModel(json: json)
                self.user = user
                UserDefaultsService().set(value: user.id, forKey: .user)
                print("useruser \(json)")
                userModel(user)
            case let .failure(error):
                print("error to load user data: \(error)")
            }
        }
        }else{
            guard let user = user else {
                return
            }
            userModel(user)
        }
    }
}


struct UserModel: Identifiable {
    var id: Int
    var name: String
    var email: String
    var phone: String?
    var passportPhotoLink: String
    var physicianRecPhotoLink: String
    var showDiscountBanner: Bool
    var discountAvailable: Bool
    var state: String
    var createdAt: String
    var deletedAt: String
    var enableNotifications: Bool
    var addresses: [UserDeliveryModel]

    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.email = json["email"].stringValue
        self.phone = json["phone"].stringValue
        self.passportPhotoLink = json["passportPhotoLink"].stringValue
        self.physicianRecPhotoLink = json["physicianRecPhotoLink"].stringValue
        self.state = json["state"].stringValue
        self.createdAt = json["createdAt"].stringValue
        self.deletedAt = json["deletedAt"].stringValue
        self.enableNotifications = json["enableNotifications"].boolValue
        self.addresses = json["addresses"].arrayValue.map({ UserDeliveryModel(json: $0) })
        self.discountAvailable = json["discountAvailable"].boolValue
        self.showDiscountBanner = json["showDiscountBanner"].boolValue
    }
    
}

struct UserDeliveryModel: Identifiable {
    var id: Int
    var city: String
    var addressLine1: String
    var addressLine2: String
    var latitudeCoordinate: Double
    var longitudeCoordinate: Double
    var zipCode: String
    
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.city = json["city"].stringValue
        self.addressLine1 = json["addressLine1"].stringValue
        self.addressLine2 = json["addressLine2"].stringValue
        self.latitudeCoordinate = json["latitudeCoordinate"].doubleValue
        self.longitudeCoordinate = json["longitudeCoordinate"].doubleValue
        self.zipCode = json["zipCode"].stringValue
    }
}
