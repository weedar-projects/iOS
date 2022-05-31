//
//  BrandButtonView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct BrandButtonView: View {
    @Binding var catalogFilters: CatalogFilters
    @State var brand: BrandModel
    @State var isSelected: Bool = false
    var body: some View{
        HStack{
            WebImage(url: URL(string: "\(BaseRepository().baseURL)/img/" + brand.imageLink))
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            Text("\(brand.name)")
                .textDefault()
        }
        .padding(12)
        .overlay(
            //color
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.col_gradient_blue_first : Color.col_borders, lineWidth: 2)
                .frame(height: 46)
        )
        .frame(height: 48)
        .background(Color.col_blue_main.opacity(isSelected ? 0.05 : 0).cornerRadius(12))
        .onAppear {
            if catalogFilters.brands == nil {
                catalogFilters.brands = Set<Int>()
            }
            isSelected = catalogFilters.brands?.contains(brand.id) ?? false
        }
        .onTapGesture {
            itemAction()
        }
        
    }
    
    private func itemAction() {
        isSelected.toggle()
        
        if isSelected {
            catalogFilters.brands?.insert(brand.id)
        } else {
            catalogFilters.brands?.remove(brand.id)
        }
    }
}
