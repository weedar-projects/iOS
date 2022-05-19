//
//  SecureInput.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 01.09.2021.
//

import SwiftUI

struct SecureInput: View {
    // MARK: - Properties
    let placeholder: String
    @State private var showText: Bool = false
    @Binding var text: String
    var onCommit: (()->Void)?
    
    
    // MARK: - View
    var body: some View {
        HStack {
            ZStack {
                SecureField(placeholder, text: $text, onCommit: {
                    onCommit?()
                })
                .opacity(showText ? 0 : 1)
                
                if showText {
                    HStack {
                        Text(text)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            } // ZStack
            
            Image(showText ? "welcome-content-eye" : "welcome-content-eye-splash")
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(.lightOnSurfaceB)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { amount in
                            showText = true
                        }
                        .onEnded { amount in
                            showText = false
                        }
                )
        } // HStack
    } // body
}
