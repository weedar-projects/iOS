//
//  SmallCategoryView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct SmallCategoryView: View {
    
    @State var category: CatalogCategoryModel
    
    var body: some View{
        ZStack{
            Image("\(category.background)")
                .resizable()
                .cornerRadius(16)
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            HStack{
                
                Text(category.name)
                    .textCustom(.coreSansC65Bold, 28, Color.col_text_main)
                    .padding(.leading, 25)
                
                Spacer()
                
//                Image(category.imagePreview)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 96)
//                    .scaleEffect(1.2)
//                    .mask(Rectangle()
//                            .frame(width: 96, height: 96)
//                            .cornerRadius(16)
//                    )
            }
        }
        
        
    }
}
