//
//  CustomProgressBar.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 08.04.2022.
//

import SwiftUI

struct CustomProgressBar: View {
    
    @Binding var value: Float
    
    var body: some View {

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.col_white.opacity(0.5))
                    .border(Color.white, width: 1)
                
                Rectangle()
                    .fill(LinearGradient(colors: [Color.col_white, Color.col_blue_loader_1, Color.col_blue_loader_2, Color.col_blue_loader_3], startPoint: .leading, endPoint: .trailing))
                    .frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .animation(.linear)
            }
        }
        .frame(height: 6)
        
    }
}
