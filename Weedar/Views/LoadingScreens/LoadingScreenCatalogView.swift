//
//  LoadingScreenCatalogView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 08.04.2022.
//

import SwiftUI

struct LoadingScreenCatalogView: View {
    var body: some View {
        LazyVStack {
            ShimmerView()
                .cornerRadius(21)
                .frame(width: 180, height: 42)
                .hLeading()
            
            ShimmerView()
                .cornerRadius(16)
                .frame(height: 153)
            
            ForEach(0..<3){ _ in
                ShimmerView()
                    .cornerRadius(16)
                    .frame(height: 96)
            }
            
            ShimmerView()
                .cornerRadius(16)
                .frame(height: 153)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct LoadingScreenCatalogView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreenCatalogView()
    }
}
