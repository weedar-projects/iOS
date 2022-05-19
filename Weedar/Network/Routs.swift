//
//  Routs.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 30.03.2022.
//

import SwiftUI


enum Routs: String {
    
    case empty = ""

    case getCatalogCategory = "/type"
    
    case getProductsList = "/product"
    case getProductById = "/product/"
  
    case getOrderById = "/order"
    
    case getEffects = "/effect"
    case getBrands = "/brand"
    
    case getOrdersList = "/order/user/"
    
    case user = "/user"
    
    case userRegister = "/user/register"
    
    case getCurrentUserInfo = "/user/current"
    
    case getPrivateImg = "/private/img/"
    
    case sendSupportMessage = "/support"
    
    case checkArea = "/area/check"
    
    case getAviableVersions = "/versions"
    
    case cart = "/cart"

}
