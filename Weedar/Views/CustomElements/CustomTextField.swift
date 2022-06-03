//
//  CustomTextField.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI

enum TextFieldState{
    case def
    case success
    case error
}

struct CustomTextField: View {
    @Binding var text: String
    @Binding var state: TextFieldState
    @State var title: String = "Title"
    @State var placeholder: String = "PlaceHolder"
    @State var keyboardType: UIKeyboardType = .default
    @State var contentType: UITextContentType?
    @State var focused: Bool = false
    @State private var strokeColor = Color.col_borders
    
    var body: some View {
        VStack{
            Text(title)
                .hLeading()
                .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 14))
                .padding(.leading, 12)
                .opacity(0.7)
            
            ZStack{
                TextFieldWrapper(text: $text, placeholder: placeholder, keyboardType: keyboardType, contentType: contentType)
                    .padding(.leading, 12)
            }
            .frame(height: 48)
            .overlay(
                //color
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(strokeColor, lineWidth: 2)
                        .frame(height: 48)     
                )
            
        }
        .padding(.horizontal, 24)
        .onChange(of: state) { newValue in
            switch newValue{
            case .def:
                strokeColor = Color.col_borders
            case .success:
                strokeColor = Color.col_green_second
            case .error:
                strokeColor = Color.col_red_second
            }
        }
        
    }
}
