//
//  EffectsRowView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI


struct EffectsRowView: View {
    
    @Binding var catalogFilters: CatalogFilters
    
    @Binding var effects: [EffectModel]
    
    
    var body: some View{
        VStack{
            //title
            Text("Effects")
                .textCustom(.coreSansC45Regular, 14, Color.col_text_main)
                .hLeading()
                .padding(.leading, 36)
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8){
                    ForEach(effects, id: \.self) { effect in
                        EffectButtonView(catalogFilters: $catalogFilters, effect: effect)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
