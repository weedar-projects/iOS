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
                    ZStack{
                        getBGColor().first
                        
                        Capsule()
                            .fill(getBGColor().last!)
                            .blur(radius: 12)
                            .scaleEffect(CGSize(width: 0.75, height: 0.4))
                            
                    }
                    .clipShape(Capsule())
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
//            Processing
        case 1...4:
            return Color.col_orange_main
//            Packing
        case 5:
            return Color.col_violet_status_text
//            delivery
        case 6:
            return Color.col_blue_main
//            Delivered
        case 7...8:
            return Color.col_green_main
//            Canceled
        case 10:
            return Color.col_pink_status_text
            
        default:
            return Color.col_pink_main
        }
    }
    
    
    private func getBGColor() -> [Color] {
        switch status {
            //proccesing
        case 1...4:
            return [Color.col_gradient_orange_first, Color.col_gradient_orange_second]
            //packing
        case 5:
            return [Color.col_violet_status_bg, Color.col_white]
            //delivery
        case 6:
            return [Color.col_gradient_blue_first, Color.col_gradient_blue_second]
            //delivered
        case 7...8:
            return [Color.col_gradient_green_first, Color.col_gradient_green_second]
            //cancel
        case 10:
            return [Color.col_gradient_pink_first, Color.col_gradient_pink_second]
        default:
            return [Color.col_gradient_blue_first, Color.col_gradient_blue_second]
        }
    }
}
