//
//  CustomSecureTextField.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 28.02.2022.
//

import SwiftUI

struct CustomSecureTextField: View {
    
    @Binding var text: String
    @Binding var state: TextFieldState
    @State var title: String = "Title"
    @State var placeholder: String = "PlaceHolder"
    @State private var focused: Bool = false
    @State var showPassword = false
    @State private var strokeColor = Color.col_borders
    
    var body: some View {
        VStack{
            //textfield placeholder
            Text(title)
                .hLeading()
                .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 14))
                .padding(.leading, 12)
                .opacity(0.7)
            
            
            ZStack{
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 2)
                    .frame(height: 48)
                HStack{
                    if showPassword{
                        PasswordTextFieldWrapper(text: $text,
                                                 isSecureTextEntry: .constant(false),
                                                 becomeFirstResponder: .constant(false),
                                                 placeholder: placeholder)
                        .padding(.leading, 12)
                            
                            
                    } else {
                        PasswordTextFieldWrapper(text: $text,
                                                 isSecureTextEntry: .constant(true),
                                                 becomeFirstResponder: .constant(false),
                                                 placeholder: placeholder)
                        .padding(.leading, 12)
                    }
                    
                    Spacer()
                    //show password button
                    Button {
                        self.showPassword.toggle()
                    } label: {
                        Image(showPassword ?  "welcome-content-eye" : "welcome-content-eye-splash" )
                            .frame(width: 24, height: 24, alignment: .center)
                            .foregroundColor(.lightOnSurfaceB)
                            .opacity(0.3)
                    }
                    .padding(.trailing, 14)
                }
            }
            .frame(height: 48)
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
