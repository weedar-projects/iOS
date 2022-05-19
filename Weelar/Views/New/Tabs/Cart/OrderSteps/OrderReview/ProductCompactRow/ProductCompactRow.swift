//
//  ProductCompactRow.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 14.03.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductCompactRow: View {
    
    @State var data: OrderDetailModel
    @State var lightText = false
    
    var body: some View{
        HStack{
            WebImage(url: URL(string: "\(BaseRepository().baseURL)/img/" + data.product.imageLink))
                    .placeholder(
                        Image("Placeholder_Logo")
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .mask(Rectangle()
                            .frame(width: 32, height: 32)
                    )
            
            VStack(alignment: .leading,spacing: 7){
                Text("\(data.product.name)")
                    .textCustom(.coreSansC45Regular, 16, lightText ? Color.col_text_white : Color.col_text_main)

                Text("\(String(format: "%.2f", data.product.gramWeight))g")
                    .textCustom(.coreSansC45Regular, 12, lightText ? Color.col_text_white.opacity(0.7) : Color.col_text_second)

                
            }
            .padding(.leading, 12)
            
            VStack(alignment: .trailing,spacing: 7){
                Text("$\(String(format: "%.2f", data.product.price))")
                    .textCustom(.coreSansC65Bold, 16,  lightText ? Color.col_text_white : Color.col_text_main)
                
                Text("x\(data.quantity)")
                    .textCustom(.coreSansC45Regular, 12, lightText ? Color.col_text_white.opacity(0.7) : Color.col_text_second)

            }
            .hTrailing()
        }
        .padding(16)
    }
}
