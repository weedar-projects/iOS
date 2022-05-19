//
//  TextExtension.swift
//  Weelar
//
//  Created by vtsyomenko on 24.09.2021.
//

import SwiftUI

extension Text {
    func getOrderStatusColor(_ statusCode: Int) -> Text{
        switch statusCode {
        case 1...4:
            return Text("Processing")
                .foregroundColor(.getColor(statusCode))
        case 5:
            return Text("Packing")
                .foregroundColor(.getColor(statusCode))
        case 6:
            return Text("In delivery")
                .foregroundColor(.getColor(statusCode))
        case 7...8:
            return Text("Delivered")
                .foregroundColor(.getColor(statusCode))
        case 10:
            return Text("Canceled")
                .foregroundColor(.getColor(statusCode))
        default:
            return Text("Drafted")
                .foregroundColor(.getColor(statusCode))
        }
    }
}
