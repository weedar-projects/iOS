//
//  LoadingScreenCart.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 16.05.2022.
//

import SwiftUI

struct LoadingScreenCart: View {
    var body: some View {
        VStack {
            ShimmerView()
                .cornerRadius(21)
                .frame(width: 180, height: 42)
                .hLeading()
            
            ShimmerView()
                .cornerRadius(16)
                .frame(height: 23)
            
            ForEach(0..<2){ _ in
                HStack{
                    ShimmerView()
                        .cornerRadius(16)
                        .frame(width: (getRect().width / 3 ) - 16, height: 96)
                    
                    Spacer()
                    
                    ShimmerView()
                        .cornerRadius(16)
                        .frame(width: (getRect().width / 2 ) - 16, height: 96)
                    
                    Spacer()
                    
                    
                    ShimmerView()
                        .cornerRadius(16)
                        .frame(width: (getRect().width / 6 ) - 16, height: 96)
                    
                }
                .padding(.top)
            }
            
            ShimmerView()
                .cornerRadius(21)
                .frame(width: 180, height: 24)
                .hLeading()
                .padding(.top)
            
            ShimmerView()
                .cornerRadius(16)
                .frame(height: 153)

            ShimmerView()
                .cornerRadius(16)
                .frame(height: 42)
                .padding(.top)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, getSafeArea().top)
    }
}

struct LoadingScreenCart_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreenCart()
    }
}
