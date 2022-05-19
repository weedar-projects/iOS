//
//  TextFieldModifier.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 16.09.2021.
//

import SwiftUI

struct TextFieldModifier: ViewModifier {
    // MARK: - Properties
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let height: CGFloat
    @Binding var borderColor: Color
    let font: CustomFont
    let size: CGFloat
    let textAlignment: TextAlignment

    
    // MARK: - View
    func body(content: Content) -> some View {
        return content
            .padding()
            .font(.custom(font.rawValue, size: size))
            .cornerRadius(cornerRadius)
            .frame(height: height, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(borderColor, lineWidth: borderWidth))
            .multilineTextAlignment(textAlignment)
    }
}


