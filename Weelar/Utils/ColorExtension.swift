//
//  ColorExtension.swift
//  Weelar
//
//  Created by vtsyomenko on 24.09.2021.
//

import SwiftUI

extension Color {
    static func getColor(_ statusCode: Int) -> Color {
        switch statusCode {
        case 1...4:
                return ColorManager.Font.Order.processingColor
        case 5:
            return ColorManager.Font.Order.packingColor
        case 6:
            return ColorManager.Font.Order.inDeliveryColor
        case 7...8:
            return ColorManager.Font.Order.deliveredColor
        case 10:
            return ColorManager.Font.Order.canceledColor
        default:
            return ColorManager.Font.Order.draftColorColor
        }
    }
}
