//
//  TextFieldStyles.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 05.08.2021.
//

import SwiftUI

struct TextFieldStyles {
    struct TextFieldStyle : ViewModifier {
        
        @Binding var strokeColor: Color
        
        func body(content: Content) -> some View {
            return content
                    .padding()
                    .cornerRadius(12.0)
                    .frame(height: 48.0, alignment: .center)
                    .overlay(
                        //color
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(strokeColor, lineWidth: 2)
                                .frame(height: 48)
                        )
        }
    }
}
