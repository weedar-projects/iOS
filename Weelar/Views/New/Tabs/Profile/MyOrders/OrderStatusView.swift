//
//  OrderStatusView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct OrderStatusView: View {
    @State var status = 0
    
    var body: some View{
        ZStack{
            Text(getTextTitle())
                .textCustom(.coreSansC65Bold, 12, getTextColor())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                        getBGColor()
                            .cornerRadius(12)
                )
        }
    }
    
    private func getTextTitle() -> String {
        switch status {
        case 1...4:
            return "Processing"
        case 5:
            return "Packing"
        case 6:
            return "In delivery"
        case 7...8:
            return "Delivered"
        case 10:
            return "Canceled"
        default:
            return "Drafted"
        }
    }
    
    private func getTextColor() -> Color {
        switch status {
        case 1...4:
            return Color.col_orange_main
        case 5:
            return Color.col_blue_main
        case 6:
            return Color.col_orange_main
        case 7...8:
            return Color.col_green_main
        case 10:
            return Color.col_red_main
        default:
            return Color.col_red_main
        }
    }
    
    
    private func getBGColor() -> Color {
        switch status {
        case 1...4:
            return Color.col_orange_statusbg
        case 5:
            return Color.col_blue_statusbg
        case 6:
            return Color.col_orange_statusbg
        case 7...8:
            return Color.col_green_statusbg
        case 10:
            return Color.col_red_statusbg
        default:
            return Color.col_red_statusbg
        }
    }
}
