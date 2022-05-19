//
//  LineLoaderView.swift
//  Weelar
//
//  Created by Galym Anuarbek on 09.11.2021.
//

import SwiftUI

public struct LineLoaderView: View {
    
    @State var alignment: Alignment = .leading
    @State var progressColor: Color
    @State var bgColor: Color
    
    public init(progressColor: Color? = nil, bgColor: Color? = nil) {
        self.progressColor = progressColor ?? Color.lightSecondaryE
        self.bgColor = bgColor ?? Color.lightSecondaryE.opacity(0.05)
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(bgColor)
                .frame(height: 4)
            
            HStack {
                if alignment != .leading {
                    Spacer()
                }
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(progressColor)
                    .frame(width: 32, height: 4, alignment: alignment)
                    .onUIKitAppear {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            alignment = .trailing
                        }
                    }
                if alignment == .leading {
                    Spacer()
                }
            }
                
        }
    }
}
