//
//  OrderNavigationManager.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 18.03.2022.
//

import SwiftUI


class OrderNavigationManager: ObservableObject {
    enum OrderNavigationViews {
        case deliveryView
        case orderReviewView
        case successView
    }
    enum OrderType{
        case delivery
        case pickup
    }
    
    @Published var orderType: OrderType = .delivery
    
    @Published var currentCreatedOrder: OrderDetailsReview =  OrderDetailsReview(orderId: 0, totalSum: 0, exciseTaxSum: 0, salesTaxSum: 0, localTaxSum: 0, taxSum: 0, sum: 0, state: 0, fullAdress: "",username: "",phone: "",partnerPhone: "", partnerName: "", partnerAdress: "")
    
    @Published var showDeliveryView = false{
        didSet{
            print("showDeliveryView: \(showDeliveryView)")
        }
    }
    
    @Published var showOrderReviewView = false{
        didSet{
            print("showOrderReviewView: \(showOrderReviewView)")
        }
    }
    @Published var showOrderSuccessView = false{
        didSet{
            print("showOrderSuccessView: \(showOrderSuccessView)")
        }
    }
    
    @Published var needToShowDocumentCenter = false{
        didSet{
            print("needToShowDocumentCenter: \(needToShowDocumentCenter)")
        }
    }
    
    @Published var showPickUpView = false{
        didSet{
            print("showPickUpView: \(showPickUpView)")
        }
    }
    
    func hideAll() {
        showDeliveryView = false
        showOrderReviewView = false
        showOrderSuccessView = false
    }
}
