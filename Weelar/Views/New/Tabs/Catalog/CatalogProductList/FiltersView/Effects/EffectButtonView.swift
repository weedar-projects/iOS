//
//  EffectButtonView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct EffectButtonView: View {
    @Binding var catalogFilters: CatalogFilters
    @State var effect: EffectModel
    @State var isSelected: Bool = false
    var body: some View{
        
        HStack{
            Text("\(effect.emoji) \(effect.name)")
                .textDefault()
        }
        .padding(12)
        .overlay(
            //color
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.col_purple_main : Color.col_borders, lineWidth: 2)
                .frame(height: 46)
        )
        .frame(height: 48)
        .background(Color.col_purple_main.opacity(isSelected ? 0.05 : 0))
        .onAppear {
            if catalogFilters.effects == nil {
                catalogFilters.effects = Set<Int>()
            }
            isSelected = catalogFilters.effects?.contains(effect.id) ?? false
        }
        .onTapGesture {
            itemAction()
        }
        
    }
    private func itemAction() {
        isSelected.toggle()
        
        if isSelected {
            catalogFilters.effects?.insert(effect.id)
        } else {
            catalogFilters.effects?.remove(effect.id)
        }
    }
}
