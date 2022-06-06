//
//  MainButton.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI

struct MainButton: View {
      
    @State var title: String = ""

    @State var icon: String?
    
    @State var iconSize: CGFloat = 24
    
    var action: () -> Void
    
    var body: some View {
        ZStack{
            
            HStack{
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(Color.col_text_white)
                }
                Text(title.localized)
                    .offset(y: 2)
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_white)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.col_black)
            .cornerRadius(12)
            
        }
        .onTapGesture {
            action()
        }
        
        
    }
}
