//
//  ProductDetailedBodyView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct ProductDetailedBodyView<Content: View>: View {
    @Binding var imageSize: Double
    @Binding var scrollOffset: Double
    
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack {
            GeometryReader { outsideProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        GeometryReader { insideProxy in
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 0)
                                .onChange(of: insideProxy.frame(in: .global).minY) { _ in
                                    scrollOffset = Double(outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY)
                                    if scrollOffset < 0.0 {
                                        imageSize =  1.0 + (-scrollOffset * 0.99)
                                    }
                                    print(scrollOffset)
                                }
                        }
                        ZStack{
                            Rectangle()
                                .fill(Color.col_white)
                                .frame(width: getRect().width, height: 20)
                                .cornerRadius(radius: 24, corners: [.topRight, .topLeft])
                                .shadow(color: Color.col_black.opacity(0.1), radius: 10, x: 0, y: -10)
                                .vTop()
                                .offset(y: 10)
                            
                            VStack(spacing: 0) {
                                content
                                    .hLeading()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white.cornerRadius(radius: 24, corners: [.topRight, .topLeft]))
                            
                        }
                        Rectangle()
                            .fill(Color.col_white)
                            .frame(width: 10, height: 150)
                    }
   
                    Rectangle()
                        .fill(Color.col_white)
                        .frame(width: 10, height: 150)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom) //Vstack
        .offset(y: getRect().height / 5)
    }
}
