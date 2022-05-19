//
//  ColorManager.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 03.08.2021.
//

import SwiftUI

struct ColorManager {

    static let backgroundColor = Color(#colorLiteral(red: 0.9043055177, green: 0.9343693852, blue: 0.9293699861, alpha: 1))
    static let fontColor = Color(#colorLiteral(red: 0.04705882353, green: 0.06666666667, blue: 0.137254902, alpha: 1))
    static let errorColor = Color(#colorLiteral(red: 0.9725490196, green: 0.3607843137, blue: 0.3137254902, alpha: 1))
    static let borderColor = Color(#colorLiteral(red: 0.9098039216, green: 0.9333333333, blue: 0.9294117647, alpha: 1))
    
    struct Buttons {
        static let buttonInactiveColor = Color(#colorLiteral(red: 0.9987453818, green: 0.9990281463, blue: 0.7765948176, alpha: 1))
        static let buttonActiveColor = Color(#colorLiteral(red: 0.9882352941, green: 1, blue: 0, alpha: 1))
        static let buttonTextInactiveColor = Color(#colorLiteral(red: 0.6979846954, green: 0.6980700493, blue: 0.6979557276, alpha: 1))
        static let buttonSecondaryColor = Color(#colorLiteral(red: 0.5098039216, green: 0.07843137255, blue: 0.862745098, alpha: 1)) // 3CAA6E
    }
    
    struct Font {
        static let currencyColor = Color(#colorLiteral(red: 0.2352941176, green: 0.431372549, blue: 0.3960784314, alpha: 1))
        static let darkColor = Color(#colorLiteral(red: 0.3333333333, green: 0.3450980392, blue: 0.3960784314, alpha: 1))
        
        struct Order {
            static let packingColor = Color(#colorLiteral(red: 0.2941176471, green: 0.3921568627, blue: 1, alpha: 1))
            static let inDeliveryColor = Color(#colorLiteral(red: 1, green: 0.6549019608, blue: 0.2470588235, alpha: 1))
            static let deliveredColor = Color(#colorLiteral(red: 0.2352941176, green: 0.6666666667, blue: 0.431372549, alpha: 1))
            static let canceledColor = Color(#colorLiteral(red: 1, green: 0.1960784314, blue: 0, alpha: 1))
            static let processingColor = Color(#colorLiteral(red: 0.9960784314, green: 0.8588235294, blue: 0.1921568627, alpha: 1))
            static let draftColorColor = Color(#colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1))
        }
        
        struct Cart {
            static let errorColor = Color(#colorLiteral(red: 0.9725490196, green: 0.3607843137, blue: 0.3137254902, alpha: 1))
            static let warningColor = Color(#colorLiteral(red: 0.9215686275, green: 0.6666666667, blue: 0.003921568627, alpha: 1))
        }
    }
    
    struct Profile {
        static let lilacColor = Color(#colorLiteral(red: 0.5098039216, green: 0.07843137255, blue: 0.862745098, alpha: 1)) // 3CAA6E
    }
    
    struct Catalog {
        struct Category {
            static let flowerColor = Color(#colorLiteral(red: 0.9308469892, green: 0.9662037492, blue: 0.9435467124, alpha: 1)) // 3CAA6E
            static let vapeColor = Color(#colorLiteral(red: 0.9275067449, green: 0.9405969977, blue: 1, alpha: 1)) // 4B64FF
            static let edibleColor = Color(#colorLiteral(red: 0.9515854716, green: 0.9153504372, blue: 0.9857437015, alpha: 1)) // 8214DC
            static let prerollColor = Color(#colorLiteral(red: 1, green: 0.9185438752, blue: 0.9200072885, alpha: 1)) // FF0023
            static let concentrateColor = Color(#colorLiteral(red: 1, green: 0.927200377, blue: 0.9108052254, alpha: 1))// FF3200
            static let tinctureColor = Color(#colorLiteral(red: 0.9979972243, green: 0.9846861959, blue: 0.932033658, alpha: 1)) // FEDB31
            static let plantsColor = Color(#colorLiteral(red: 0.9308469892, green: 0.9662037492, blue: 0.9435467124, alpha: 1)) // 3CAA6E // 10
            static let seedsColor = Color(#colorLiteral(red: 0.8614215255, green: 0.9323062897, blue: 0.8871565461, alpha: 1)) // 3CAA6E // 20
        }
        
        struct Item {
            static let backgroundBlue = Color(#colorLiteral(red: 0.9641625285, green: 0.9682546258, blue: 1, alpha: 1))
            static let backgroundRed = Color(#colorLiteral(red: 1, green: 0.9593737721, blue: 0.9469228387, alpha: 1))
            static let backgroundYellow = Color(#colorLiteral(red: 0.9994327426, green: 1, blue: 0.9306704998, alpha: 1))
            static let backgroundGreen = Color(#colorLiteral(red: 0.9658824801, green: 0.9810553193, blue: 0.9718800187, alpha: 1))
            static let textGreen = Color(#colorLiteral(red: 0.2352941176, green: 0.6666666667, blue: 0.431372549, alpha: 1))
            static let textBlue = Color(#colorLiteral(red: 0.2941176471, green: 0.3921568627, blue: 1, alpha: 1))
            static let textRed = Color(#colorLiteral(red: 1, green: 0.1960784314, blue: 0, alpha: 1))
            static let priceColor = Color(#colorLiteral(red: 0.5098039216, green: 0.07843137255, blue: 0.862745098, alpha: 1))
            static let fontGray = Color(#colorLiteral(red: 0.5999526381, green: 0.6000268459, blue: 0.5999273658, alpha: 1))
            static let dotGray = Color(#colorLiteral(red: 0.7999381423, green: 0.8000349402, blue: 0.7999051213, alpha: 1))
            static let gradientEnd = Color(#colorLiteral(red: 1, green: 0.4, blue: 0.4823529412, alpha: 1))
            static let gradientStart = Color(#colorLiteral(red: 0.5764705882, green: 0.6352941176, blue: 1, alpha: 1))
        }
    }
}
