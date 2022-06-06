//
//  LoadingCatalogProductsListView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 01.06.2022.
//

import SwiftUI

struct LoadingCatalogProductsListView: View {
    var body: some View {
        LazyVStack{
            Group{
                ShimmerView()
                    .frame(height: 48)
                ShimmerView()
                    .frame(width: 100,height: 28)
                
                ForEach(0..<8){_ in
                    HStack{
                        ShimmerView()
                            .frame(width: getRect().width / 4,height: 113)
                            .cornerRadius(12)
                        Spacer()
                        
                        ShimmerView()
                            .frame(height: 113)
                            .cornerRadius(12)
                    }
                    
                }
            }
            .cornerRadius(12)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        
        
    }
}

struct LoadingCatalogProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingCatalogProductsListView()
    }
}
