//
//  OrderState.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 21.04.2022.
//

import SwiftUI

enum OrderState: Int {
    case processing
    case packing
    case inDelivery
    case canceled
    static var allCases: [OrderState] = [.processing, .packing, .inDelivery]
    
    var color: Color {
        switch self {
        case .processing: return ColorManager.Font.Order.processingColor
        case .packing: return ColorManager.Font.Order.packingColor
        case .inDelivery: return ColorManager.Font.Order.inDeliveryColor
        case .canceled: return ColorManager.Font.Order.canceledColor
        }
    }
    
    var title: String {
        switch self {
        case .processing: return "Processing"
        case .packing: return "Packing"
        case .inDelivery: return "In delivery"
        case .canceled: return "Cancelled"
        }
    }
    
    var description: String {
//        switch self {
//        case .processing: return "Processing"
//        case .packing: return "Packing"
//        case .inDelivery: return "In delivery"
//        case .delivered: return "Delivered"
//        case .canceled: return "Cancelled"
//        }
        return "It has been proceed and will be delivered within 1 hour.\nOur courier will get in touch with you to get drop details. Сourier may ask ID card to verify your identity."
    }
}
