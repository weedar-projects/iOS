//
//  UserDefaultsService.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 18.08.2021.
//

import Combine
import Foundation

class UserDefaultsService {
    // MARK: - Properties
    enum UserDefaultWeelar: String {
        case user = "weelarUserId"
        case phone = "weelarPhone"
        case notifOrder = "notifOrder"
        case fcmGranted = "fcmGranted"
        case fcmEnabled = "fcmEnabled"
        case userVerified = "userVerified"
        case userHasRecPhoto = "userHasRecPhoto"
        case productFilters = "productFilters"
        case accessToken = "accessToken"
        
        case showButtonShapeAlert = "showButtonShapeAlert"
        
        
        case verificationID = "verificationID"
        
        // User Session Manager
        case userIsLogged = "userIsLogged"
        case needToFillUserData = "needToFillUserData"
        case showOnboarding = "showOnboarding"
        case animDoc = "animDoc"
        
        
        // Delivery details
        case userFullName = "userFullName"
        case latitudeCoordinate = "latitudeCoordinate"
        case longitudeCoordinate = "longitudeCoordinate"
        case userAddress = "userAddress"
        case addressLine1 = "addressLine1"
        case addressLine2 = "addressLine2"
        case zipCode = "zipCode"
        case city = "city"
        
        case animCart = "animCart"
        
        case userDiscountBanner = "userDiscountBanner"
        
        case needToOrderTrackerAnimation  = "needToOrderTrackerAnimation"
        
    }

    let defaults = UserDefaults.standard

    var isNotificationsEnabled: Bool {
        return (get(fromKey: .fcmEnabled) as? Bool ?? true) && (get(fromKey: .fcmGranted) as? Bool ?? false)
    }
    
    
    // MARK: - Custom functions
    func set(value: Any, forKey key: UserDefaultWeelar) {
        defaults.set(value, forKey: key.rawValue)
    }

    func get(fromKey key: UserDefaultWeelar) -> Any? {
        return defaults.object(forKey: key.rawValue)
    }

    func remove(key: UserDefaultWeelar) {
        defaults.removeObject(forKey: key.rawValue)
    }
    
    func savePersonalUserData(data: UserPersonalData){
        
        if let userFullName = data.userFullName {
            set(value:  userFullName, forKey: UserDefaultWeelar.userFullName)
        }
        if let phone = data.phone {
            set(value: phone, forKey: UserDefaultWeelar.phone)
        }
        if let address = data.address {
            set(value: address, forKey: UserDefaultWeelar.userAddress)
        }
        if let addressLine1 = data.addressLine1 {
            set(value:  addressLine1, forKey: UserDefaultWeelar.addressLine1)
        }
        if let addressLine2 = data.addressLine2 {
            set(value:  addressLine2, forKey: UserDefaultWeelar.addressLine2)
        }
        if let zipCode = data.zipCode {
            set(value:  zipCode, forKey: UserDefaultWeelar.zipCode)
        }
        if let city = data.city {
            set(value:  city, forKey: UserDefaultWeelar.city)
        }
        if let longitudeCoordinate = data.longitudeCoordinate {
            set(value:  longitudeCoordinate, forKey: UserDefaultWeelar.longitudeCoordinate)
        }
        if let latitudeCoordinate = data.latitudeCoordinate {
            set(value:  latitudeCoordinate, forKey: UserDefaultWeelar.latitudeCoordinate)
        }
        if let fcmEnabled = data.fcmEnabled {
            set(value:  fcmEnabled, forKey: UserDefaultWeelar.fcmEnabled)
        }
        if let fcmGranted = data.fcmGranted {
            set(value:  fcmGranted, forKey: UserDefaultWeelar.fcmGranted)
        }
    }
    
    func getPersonalUserData() -> UserPersonalData{
        let userFullName = get(fromKey: .userFullName) as? String ?? ""
        let phone = get(fromKey: .phone) as? String ?? ""
        let address = get(fromKey: .userAddress) as? String ?? ""
        let addressLine1 = get(fromKey: .addressLine1) as? String ?? ""
        let addressLine2 = get(fromKey: .addressLine2) as? String ?? ""
        let zipCode = get(fromKey: .zipCode) as? String ?? ""
        let city = get(fromKey: .city) as? String ?? ""
        let longitudeCoordinate = get(fromKey: .longitudeCoordinate) as? Double ?? 0
        let latitudeCoordinate = get(fromKey: .latitudeCoordinate) as? Double ?? 0
        let fcmGranted = get(fromKey: .fcmGranted) as? Bool ?? false
        let fcmEnabled = get(fromKey: .fcmEnabled) as? Bool ?? false
        return UserPersonalData(userFullName: userFullName, phone: phone, address: address, addressLine1: addressLine1, addressLine2: addressLine2, zipCode: zipCode, city: city, latitudeCoordinate: latitudeCoordinate, longitudeCoordinate: longitudeCoordinate)
    }
    
    func removePersonalUserData(){
        remove(key: UserDefaultWeelar.userFullName)
        remove(key: UserDefaultWeelar.phone)
        remove(key: UserDefaultWeelar.userAddress)
        remove(key: UserDefaultWeelar.addressLine1)
        remove(key: UserDefaultWeelar.addressLine2)
        remove(key: UserDefaultWeelar.zipCode)
        remove(key: UserDefaultWeelar.city)
        remove(key: UserDefaultWeelar.longitudeCoordinate)
        remove(key: UserDefaultWeelar.latitudeCoordinate)
    }
}


struct UserPersonalData{
    var userFullName: String?
    var phone: String?
    var address: String?
    var addressLine1: String?
    var addressLine2: String?
    var zipCode: String?
    var city: String?
    var latitudeCoordinate: Double?
    var longitudeCoordinate: Double?
    var fcmGranted: Bool?
    var fcmEnabled: Bool?
}

extension UserDefaults {

    // MARK: - Types

    struct Item<T> {
        fileprivate let key: String

        public init(key: String) {
            self.key = key
        }
    }

    struct CodableItem<Root: Codable, T> {
        fileprivate let key: String
        fileprivate let getter: (Root?) -> T
        fileprivate let updater: (Root?, T) -> Root?

        public init(key: String, getter: @escaping (Root?) -> T, updater: @escaping (Root?, T) -> Root?) {
            self.key = key
            self.getter = getter
            self.updater = updater
        }
    }

}

// MARK: - Subscripts

extension UserDefaults {

    subscript(item: Item<Bool>) -> Bool {
        get { bool(forKey: item.key) }
        set { set(newValue, forKey: item.key) }
    }

    subscript<T>(item: Item<T>) -> T? {
        get { value(forKey: item.key) as? T }
        set { set(newValue, forKey: item.key) }
    }

    subscript<T: RawRepresentable>(item: Item<T>) -> T? {
        get {
            guard let rawValue = value(forKey: item.key) as? T.RawValue else {
                return nil
            }
            return T(rawValue: rawValue)
        }
        set { set(newValue?.rawValue, forKey: item.key) }
    }

    subscript<Root, V>(codableItem: CodableItem<Root, V>) -> V {
        get { codableItem.getter(self[codable: codableItem.key]) }
        set { self[codable: codableItem.key] = codableItem.updater(self[codable: codableItem.key], newValue) }
    }

    subscript<Root, V>(has codableItem: CodableItem<Root, V>) -> Bool {
        data(forKey: codableItem.key) != nil
    }

}

// MARK: - Publishers

extension UserDefaults {

    func publisher(_ item: Item<Bool>) -> AnyPublisher<Bool, Never> {
        publisher { self[item] }
    }

    func publisher<T: Equatable>(_ item: Item<T>) -> AnyPublisher<T?, Never> {
        publisher { self[item] }
    }

    func publisher<T: Equatable & RawRepresentable>(_ item: Item<T>) -> AnyPublisher<T?, Never> {
        publisher { self[item] }
    }

    func publisher<Root, T: Equatable>(_ codableItem: CodableItem<Root, T>) -> AnyPublisher<T, Never> {
        publisher { self[codableItem] }
    }

}

private extension UserDefaults {

    subscript<T: Codable>(codable key: String) -> T? {
        get { data(forKey: key).flatMap { try? JSONDecoder().decode(T.self, from: $0) } }
        set { set(newValue.flatMap { try? JSONEncoder().encode($0) }, forKey: key) }
    }

    func publisher<T: Equatable>(_ getter: @escaping () -> T) -> AnyPublisher<T, Never> {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .prepend(())
            .map(getter)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

}

extension UserDefaults.Item {

    static var tabBarShow: UserDefaults.Item<Bool> {
        UserDefaults.Item(key: "tabBarShow")
    }
    
    static var userHasRecPhoto: UserDefaults.Item<Bool> {
        UserDefaults.Item(key: "userHasRecPhoto")
    }

}
