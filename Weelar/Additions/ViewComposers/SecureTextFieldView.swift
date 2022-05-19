//
//  SecureTextFieldView.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 17.09.2021.
//

import SwiftUI

struct SecureTextFieldView: View {
    // MARK: - Properties
    private var placeholder: String
    @Binding private var text: String
    @State private var isSecured: Bool = true
    
    
    // MARK: - Initialization
    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    
    // MARK: - View
    var body: some View {
        ZStack(alignment: .trailing) {
            if isSecured {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            // Action button (hide/show password)
            Button(action: {
                isSecured.toggle()
            }) {
                Image(isSecured ? "welcome-content-eye-splash" : "welcome-content-eye")
                    .frame(width: 24, height: 24, alignment: .center)
                    .foregroundColor(.lightOnSurfaceB)
            }
        } // ZStack
    } // body
}
