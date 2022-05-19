//
//  KeychainService.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 11.08.2021.
//

import Foundation

class KeychainService {

    enum KeychainWeelar: String {
        case accessToken = "accessToken"
    }
    
    static func updatePassword(_ password: String, serviceKey: String) {
    guard let dataFromString = password.data(using: .utf8) else { return }

    let keychainQuery: [CFString : Any] = [kSecClass: kSecClassGenericPassword,
                                           kSecAttrService: serviceKey,
                                           kSecValueData: dataFromString]
    SecItemDelete(keychainQuery as CFDictionary)
    SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    static func updatePassword(_ password: String, serviceKey: KeychainWeelar) {
        updatePassword(password, serviceKey: serviceKey.rawValue)
    }

    static func removePassword(serviceKey: KeychainWeelar) {
        removePassword(serviceKey: serviceKey.rawValue)
    }

    static func removePassword(serviceKey: String) {

    let keychainQuery: [CFString : Any] = [kSecClass: kSecClassGenericPassword,
                                           kSecAttrService: serviceKey]

    SecItemDelete(keychainQuery as CFDictionary)
    }

    static func loadPassword(serviceKey: KeychainWeelar) -> String? {
        return loadPassword(serviceKey: serviceKey.rawValue)
    }

    static func loadPassword(serviceKey: String) -> String? {
    let keychainQuery: [CFString : Any] = [kSecClass : kSecClassGenericPassword,
                                           kSecAttrService : serviceKey,
                                           kSecReturnData: kCFBooleanTrue as Any,
                                           kSecMatchLimitOne: kSecMatchLimitOne]

    var dataTypeRef: AnyObject?
        SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        guard let retrievedData = dataTypeRef as? Data else { return nil }

        return String(data: retrievedData, encoding: .utf8)
    }

    static func flush()  {
        let secItemClasses =  [kSecClassGenericPassword]
        for itemClass in secItemClasses {
          let spec: NSDictionary = [kSecClass: itemClass]
          SecItemDelete(spec)
        }
    }
}
