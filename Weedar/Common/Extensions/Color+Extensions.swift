//
//  Color+Extensions.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 14.09.2021.
//

import SwiftUI

extension Color {
    static let lightPrimary = Color("lightPrimary")
    static let lightOnSurfaceA = Color("lightOnSurfaceA")
    static let lightOnSurfaceB = Color("lightOnSurfaceB")
    static let lightSecondaryA = Color("lightSecondaryA")
    static let lightSecondaryB = Color("lightSecondaryB")
    static let lightSecondaryC = Color("lightSecondaryC")
    static let lightSecondaryD = Color("lightSecondaryD")
    static let lightSecondaryE = Color("lightSecondaryE")
    static let lightSecondaryF = Color("lightSecondaryF")
    static let textFieldGray = Color("textFieldGray")
    
    
    static let col_bg_main = Color("col_bg_main")
    static let col_bg_second = Color("col_bg_second")
    static let col_black = Color("col_black")
    static let col_borders = Color("col_borders")

    static let col_purple_main = Color("col_purple_main")
    static let col_pink_main = Color("col_pink_main")
    static let col_pink_status_text = Color("col_pink_status_text")
    static let col_violet_status_bg = Color("col_violet_status_bg")
    static let col_violet_status_text = Color("col_violet_status_text")
    
    static let col_pink_button = Color("col_pink_button")
    static let col_red_second = Color("col_pink_second")
    static let col_orange_main = Color("col_orange_main")
    static let col_orange_second = Color("col_orange_second")
    static let col_text_main = Color("col_text_main")
    static let col_text_second = Color("col_text_second")
    static let col_text_white = Color("col_text_white")
    static let col_white = Color("col_white")
    static let col_yellow_main = Color("col_yellow_main")
    static let col_yellow_second = Color("col_yellow_second")
    static let col_blue_main = Color("col_blue_main")
    static let col_blue_second = Color("col_blue_second")
    static let col_blue_dark = Color("col_blue_dark")
    static let col_blue_alert_bg = Color("col_blue_alert_bg")
    
    static let col_gray_main = Color("col_gray_main")
    static let col_gray_second = Color("col_gray_second")
    
    static let col_green_main = Color("col_green_main")
    static let col_green_second = Color("col_green_second")
    
    static let col_gradient_orange_first = Color("col_gradient_orange_first")
    static let col_gradient_orange_second = Color("col_gradient_orange_second")
    
    static let col_toggle_disable = Color("col_toggle_disable")
    
    static let col_gray_button = Color("col_gray_button")
    
    //Discount
    static let col_red_discount_bg = Color("col_red_discount_bg")
    static let col_blue_dark_discount_bg = Color("col_blue_dark_discount_bg")
    
    //AR
    static let col_cold_ar_light = Color("col_cold_ar_light")
    static let col_warm_ar_light = Color("col_warm_ar_light")
    
    
    //order statuses
    static let col_blue_statusbg = Color("col_blue_statusbg")
    static let col_green_statusbg = Color("col_green_statusbg")
    static let col_orange_statusbg = Color("col_orange_statusbg")
    static let col_red_statusbg = Color("col_red_statusbg")
    
    //loader gradient
    static let col_blue_loader_1 = Color("col_blue_loader_1")
    static let col_blue_loader_2 = Color("col_blue_loader_2")
    static let col_blue_loader_3 = Color("col_blue_loader_3")
    
    //order tracker
    static let col_blue_orderTracker = Color("col_blue_orderTracker")
    static let col_green_orderTracker = Color("col_green_orderTracker")
    static let col_yellow_orderTracker = Color("col_yellow_orderTracker")
    static let col_orange_orderTracker = Color("col_orange_orderTracker")
    static let col_gray_dropdown_bg = Color("col_gray_dropdown_bg")
    static let col_gray_dropdown_button = Color("col_gray_dropdown_button")
    
    
    
    //catalog colors
    static let col_catalog_green = Color("col_catalog_green")
    static let col_catalog_red = Color("col_catalog_red")
    static let col_catalog_pink = Color("col_catalog_pink")
    
    
    //borders
    static let col_border_black = Color("col_border_black")
    
    //gradiens
    static let col_gradient_black_first = Color("col_gradient_black_first")
    static let col_gradient_black_second = Color("col_gradient_black_second")
    
    static let col_gradient_green_first = Color("col_gradient_green_first")
    static let col_gradient_green_second = Color("col_gradient_green_second")
    
    static let col_gradient_blue_first = Color("col_blue_gradient_main")
    static let col_gradient_blue_second = Color("col_blue_gradient_second")
    
    static let col_gradient_pink_first = Color("col_gradient_pink_first")
    static let col_gradient_pink_second = Color("col_gradient_pink_second")
    
    
    
}

extension Image {
    static let logoDark = Image("logo_dark")
    static let logoLight = Image("logo_light")
    static let bg_gradient_main = Image("bg_gradient_main")
    static let icon_trash = Image("trash")
    static let ticket_discount = Image("ticket_discount")
    static let ticket_discount_percent = Image("ticket_discount_percent")
    
    
}


class Gradients {
    class Radial{
        static let black = RadialGradient(colors: [Color.col_white,
                                                   Color.col_gradient_black_second],
                                          center: .center,
                                          startRadius: 10,
                                          endRadius: 100)
    }
}

