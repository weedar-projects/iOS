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
                //text placeholder
                Text(placeholder)
                    .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                    .opacity(0.3)
                    .opacity(text == "" ? 1 : 0)
                    .hLeading()
                    .padding(.leading, 12)
                    .frame(height: 48)
                    .offset(y: 2)
                    
                
                HStack{
                    if showPassword{   
                        //show Text view
                        TextField("", text: $text, onEditingChanged: { focused in
                            withAnimation(.easeIn.speed(4)){
                                self.focused = focused
                            }
                        })
                            .font(.custom(CustomFont.coreSansC45Regular.rawValue, size: 16))
                            .padding(.leading, 12)
                            
                            
                    } else {
                        
                        //hide Text view
                        SecureField("", text: $text)
                            .textDefault()
                            .padding(.leading, 12)
                            .onChange(of: text) { newValue in
                                if newValue == ""{
                                    self.focused = false
                                }else{
                                    self.focused = true
                                }
                            }
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
