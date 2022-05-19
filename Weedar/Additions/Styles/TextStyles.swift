//
//  TextStyles.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 05.08.2021.
//

import SwiftUI

struct TextStyles {
    static let appName = "WEEDAR"
    
    struct TextHeaderStyle : ViewModifier {
        var height: CGFloat = 48
        
        func body(content: Content) -> some View {
            return content
                    .padding([.top, .leading, .trailing], 16.0)
                    .frame(width: UIScreen.main.bounds.width, height: height, alignment: .leading)
                    .lineSpacing(8)
                
        }
    }
    
    struct TextBodyStyle : ViewModifier {
        var height: CGFloat = 48
        
        func body(content: Content) -> some View {
            return content
                    .frame(height: height, alignment: .leading)
                    .lineSpacing(8)
        }
    }
}


extension Text {

    enum FontStyle {
        case header, body
    }

    func fontStyle(_ style: FontStyle) -> Text {
        switch style {
        case .header:
            return foregroundColor(ColorManager.fontColor)
                    .font(.system(size: 32))
                    .fontWeight(.semibold)
        case .body:
            return foregroundColor(ColorManager.fontColor)
                    .font(.system(size: 14))
                    .fontWeight(.light)
        }
    }
}
