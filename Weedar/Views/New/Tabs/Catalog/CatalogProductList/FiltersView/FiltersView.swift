//
//  FiltersView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 04.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI


struct FiltersView: View {
    
    @StateObject var vm = FiltersVM()
        
    @ObservedObject var rootVM: CatalogProductsListVM
    
    var body: some View {
        
        VStack{
            
            Spacer()
            
            VStack{
                Button(action: {
                    withAnimation {
                        rootVM.showFilterView = false
                    }
                }, label: {
                    Image("xmark")
                        .resizable()
                        .frame(width: 12, height: 12, alignment: .center)
                })
                    .hTrailing()
                    .padding(19)
                
                Text("Filters")
                    .textTitle()
                    .hLeading()
                    .padding(.top,12)
                    .padding(.leading, 24)
                
                PriceSelector(priceFrom: $vm.priceFrom, priceTo: $vm.priceTo)
                    .padding(.top, 24)
                    .onChange(of: vm.priceFrom) { price in
                        rootVM.filters.priceFrom = price
                    }
                    .onChange(of: vm.priceTo) { price in
                        rootVM.filters.priceTo = price
                    }
                    .onAppear {
                        vm.priceFrom = Double(rootVM.filters.priceFrom ?? 0)
                        vm.priceTo = Double(rootVM.filters.priceTo ?? 199)
                    }
                
                BrandsRowView(catalogFilters: $rootVM.filters, brands: $rootVM.brands)
                
                EffectsRowView(catalogFilters: $rootVM.filters, effects: $rootVM.effects)
                    .padding(.top, 24)
                
          
                //Reset button
                ZStack{
                    HStack{
                        Image("navbar-refresh")
                            .foregroundColor(Color.col_text_main)
                        
                        Text("Reset")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                            .offset(y: 2)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color.col_gray_second)
                    .cornerRadius(12)
                }
                .onTapGesture {
                    if rootVM.canReset{
                        rootVM.getProducts(categoryId: rootVM.categoryId, filters: CatalogFilters())
                        rootVM.canReset = false
                    }
                    
                    withAnimation {
                        rootVM.filters = CatalogFilters()
                        rootVM.showFilterView = false
                    }
                    
                }
                .padding(.horizontal,24)
                .padding(.top, 24)
                
                //comfirm button
                MainButton(title: "Confirm", icon: "checkmark", iconSize: 14) {
                    rootVM.getProducts(categoryId: rootVM.categoryId, filters: rootVM.filters)
                    rootVM.canReset = true
                    
                    AnalyticsManager.instance.event(key: .filters_apply,
                                                    properties: [.category : rootVM.categoryId,
                                                                 .price_range: "\(rootVM.filters.priceFrom?.formattedString(format: .percent)) - \(rootVM.filters.priceTo?.formattedString(format: .percent))",
                                                                 .brand_name: rootVM.filters.brands ?? 0,
                                                                 .effects: rootVM.filters.effects ?? 0])
                    withAnimation {
                        rootVM.showFilterView = false
                    }
                }
                .padding(.horizontal,24)
                .padding(.top, 10)
                .padding(.bottom, 35)
            }
            .background(Color.col_white.cornerRadius(radius: 16, corners: [.topLeft,.topRight]))
        }
    }
}
