//
//  TextModifier.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 15.09.2021.
//

import SwiftUI

//OLD
struct TextModifier: ViewModifier {
    // MARK: - Properties
    let font: CustomFont
    let size: CGFloat
    let foregroundColor: Color
    let opacity: Double
    
    init(font: CustomFont, size: CGFloat, foregroundColor: Color, opacity: Double = 1) {
        self.font = font
        self.size = size
        self.foregroundColor = foregroundColor
        self.opacity = opacity
    }
    
    // MARK: - Custom functions
    func body(content: Content) -> some View {
        content
            .font(.custom(font.rawValue, size: size))
            .foregroundColor(foregroundColor.opacity(opacity))
            .background(Color.clear)
    }
}

//NEW
struct TextViewModifier: ViewModifier {
    let font: CustomFont
    let size: CGFloat
    let color: Color
    
    
    func body(content: Content) -> some View {
        content
            .font(.custom(font.rawValue, size: size))
            .foregroundColor(color)
            .lineSpacing(4.0)
            
    }
}
