//
//  LoadingScreenMyOrderView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 08.04.2022.
//

import SwiftUI

struct LoadingScreenMyOrderView: View {
    var body: some View {
        LazyVStack{
            ShimmerView()
                .cornerRadius(21)
                .frame( height: 42)
            
            ShimmerView()
                .cornerRadius(16)
                .frame(width: 100, height: 25)
                .hLeading()
                .padding(.top)
            ShimmerView()
                .cornerRadius(16)
                .frame(height: 153)
            ShimmerView()
                .cornerRadius(16)
                .frame(height: 100)
                .padding(.top)
            ShimmerView()
                .cornerRadius(16)
                .frame(width: 100, height: 25)
                .hLeading()
                .padding(.top)
            
            ShimmerView()
                .cornerRadius(16)
                .frame(height: 100)
                
            ShimmerView()
                .cornerRadius(16)
                .frame(height: 58)
                .padding(.top)

        }
        .padding(.horizontal)
    }
}

struct LoadingScreenMyOrderView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreenMyOrderView()
    }
}
