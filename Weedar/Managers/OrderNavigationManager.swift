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
