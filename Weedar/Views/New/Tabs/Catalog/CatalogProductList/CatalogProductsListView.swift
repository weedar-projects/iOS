//
//  CatalogItemListView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 17.03.2022.
//

import SwiftUI
import Amplitude

struct CatalogProductsListView: View {
    
    @StateObject var vm = CatalogProductsListVM()
    
    @EnvironmentObject var tabBarManager: TabBarManager
     
    @State var category: CatalogCategoryModel
    
    var body: some View {
        ZStack{
            
            NavigationLink(isActive: $vm.showAR) {
                
            } label: {
                EmptyView()
            }
            
            NavigationLink(isActive: $vm.showProductDetail) {
                if let product = vm.productDetail{
                    ProductDetailedView(product: product)
                        .onAppear(perform: {
                            tabBarManager.hide()
                            if UserDefaults.standard.bool(forKey: "EnableTracking"){

                            Amplitude.instance().logEvent("select_product", withEventProperties: ["category" : product.type.name, "product_id" : product.id, "price" : product.price])
                            }
                        })
//                        .onDisappear(perform: {
//                            tabBarManager.show()
//                        })
                }
            } label: {
                EmptyView()
            }.isDetailLink(false)
            
            Color.white
            
            VStack{
                CustomSearch(searchText: $vm.searchText, isEditing: $vm.searchIsEditing)
                    .zIndex(0)
               
                //filter button
                ZStack{
                    HStack{
                        Image("filters")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 11)
                            .foregroundColor(Color.col_black)
                        
                        Text("filtersview.filters_filters".localized)
                            .textCustom(.coreSansC45Regular, 14, Color.col_black)
                            .padding(.top,7)
                            .padding(.bottom,4)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.col_white)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.col_black, lineWidth: 1))
                }
                .padding(.top, 12)
                .onTapGesture {
                    withAnimation {
                        if UserDefaults.standard.bool(forKey: "EnableTracking"){

                        Amplitude.instance().logEvent("click_filters")
                        }
                        UIApplication.shared.endEditing()
                        vm.showFilterView = true
                    }
                }
                .padding(.horizontal)
                
                //product view
                ScrollView(.vertical, showsIndicators: false) {
                    //show products
                    VStack{
                        ForEach(filteredProducts(searchText: vm.searchText), id: \.self){ product in
                            
                            ProductCatalogRowView(item: product, productInCartAnimation: $vm.productInCartAnimation)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .padding(.bottom, product == vm.products.last ? 35 : 0)
                                .onTapGesture {
                                    vm.productDetail = product
                                    vm.showProductDetail.toggle()
                                }
                                .disabled(vm.productInCartAnimation)
                        }
                    }
                    .padding(.bottom, tabBarManager.showOrderTracker ? 95 : isSmallIPhone() ? 30 : 0)
                }
                .padding(.top, 12)
                
                Spacer()
            }
            //Filter View
            FilterView()
        }
        .onAppear(perform: {
            vm.categoryId = category.id
        })
        .navBarSettings(category.name)
        .onUIKitAppear {
            tabBarManager.showTracker()
            tabBarManager.show()
        }
        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    vm.showAR.toggle()
//                } label: {
//                    HStack{
//                    Image("Catalog-AR-White-Icon")
//                        .resizable()
//                        .frame(width: 13, height: 13)
//
//                        Text("AR")
//                            .textCustom(.coreSansC65Bold, 12, Color.col_text_white)
//                    }
//                    .padding(.horizontal, 13)
//                    .padding(.vertical, 5)
//                    .background(Color.col_purple_main.cornerRadius(12))
//                }
//            }
        }
    }
    
    func filteredProducts(searchText: String) -> [ProductModel] {
        if searchText.isEmpty {
            return vm.products
        }
        
        let products = vm.products.filter { item in
            let productWords = item.name.lowercased().components(separatedBy: " ")
            let res =  productWords.filter({$0.hasPrefix(vm.searchText.lowercased())})
            return !res.isEmpty
            
        }
        
        return products
    }
    
    @ViewBuilder
    func FilterView() -> some View {
        if vm.showFilterView{
            Color.col_black
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        vm.showFilterView.toggle()
                    }
                }
                .onAppear(perform: {
                    tabBarManager.hide()
                })
                .onDisappear(perform: {
                    tabBarManager.show()
                })
                .zIndex(1)
            
            FiltersView(rootVM: vm)
                .zIndex(2)
                .transition(.move(edge: .bottom))
                .edgesIgnoringSafeArea(.bottom)
                .onDisappear {
                    if UserDefaults.standard.bool(forKey: "EnableTracking"){

                    Amplitude.instance().logEvent("filter_close")
                    }
                }
        }
    }
}
