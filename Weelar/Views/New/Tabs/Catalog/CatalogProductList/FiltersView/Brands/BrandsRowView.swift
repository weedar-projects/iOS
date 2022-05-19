//
//  BrandsRowView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct BrandsRowView: View {
    
    @Binding var catalogFilters: CatalogFilters
    
    @Binding var brands: [BrandModel]
    
    
    var body: some View{
        VStack{
            //title
            Text("Brand")
                .textCustom(.coreSansC45Regular, 14, Color.col_text_main)
                .hLeading()
                .padding(.leading, 36)
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8){
                    ForEach(brands, id: \.self) { brand in
                        BrandButtonView(catalogFilters: $catalogFilters, brand: brand)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

