//
//  PickUpShopListPiker.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI

struct PickUpShopListPiker: View {
    
    @Binding var selected: PickUpShopListState
    
    var body: some View {
        HStack(spacing: 0){
            Text("See list")
                .textCustom(.coreSansC65Bold, 16, selected == .list ? Color.col_text_white : Color.col_text_main)
                .frame(width: (getRect().width / 2 - 24), height: 44)
                .background(Color.col_white.opacity(0.01))
                .onTapGesture {
                    withAnimation {
                        selected = .list
                    }
                }
            
            Text("See on map")
                .textCustom(.coreSansC65Bold, 16, selected == .map ? Color.col_text_white : Color.col_text_main)
                .frame(width: (getRect().width / 2 - 24), height: 44)
                .background(Color.col_white.opacity(0.01))
                .onTapGesture {
                    withAnimation {
                        selected = .map
                    }
                    
                }
        }
        .frame(maxWidth: .infinity)
        .background(
            HStack{
                Color.col_black
                    .frame(width: (getRect().width / 2 - 24), height: 44)
                    .cornerRadius(radius: 12, corners: selected == .map ? [.bottomRight, .topRight] : [.bottomLeft, .topLeft])
                    .animation(.interactiveSpring(response: 0.15,
                                                  dampingFraction: 0.65,
                                                  blendDuration: 1.5),
                               value: selected)
                    .offset(x: selected == .map ? (getRect().width / 2 - 24) : 0)
                    .hLeading()
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder()
                .foregroundColor(Color.col_borders)
            
        )
        .padding(.horizontal, 24)
        
    }
}
