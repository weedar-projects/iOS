//
//  LineProgressView.swift
//  Weelar
//
//  Created by Galym Anuarbek on 09.11.2021.
//

import SwiftUI

public struct LineProgressView: View {
    
    @Binding var progress: Float
    @State var progressColor: Color
    @State var bgColor: Color
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .foregroundColor(bgColor)
                .frame(width: .infinity, height: .infinity)
            
            HStack {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundColor(progressColor)
                        .frame(width: geo.size.width * CGFloat(progress), height: .infinity)
                }
            }
        }
    }
}
