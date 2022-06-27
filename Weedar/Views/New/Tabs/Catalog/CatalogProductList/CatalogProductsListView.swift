//
//  CatalogItemListView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 17.03.2022.
//

import SwiftUI
 

struct CatalogProductsListView: View {
    
    @StateObject var vm = CatalogProductsListVM()
    
    @EnvironmentObject var tabBarManager: TabBarManager
     
    @State var category: CatalogCategoryModel
    
    var body: some View {
        ZStack{
            
            NavigationLink(isActive: $vm.showAR) {
                HomeView(openProductById: 0, openByCategoryId: category.id)
            } label: {
                EmptyView()
            }
            
            NavigationLink(isActive: $vm.showProductDetail) {
                if let product = vm.productDetail{
                    ProductDetailedView(product: product)
                        .onAppear(perform: {
                            tabBarManager.hideTracker()
                            AnalyticsManager.instance.event(key: .select_product,
                                                            properties: [.category : product.type.name,
                                                                         .product_id: product.id,
                                                                         .product_price: product.price.formattedString(format: .percent)])

        
                            
                        })
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
                            .foregroundColor(Color.col_text_main)
                        
                        Text("filtersview.filters_filters".localized)
                            .textCustom(.coreSansC45Regular, 14, Color.col_text_main)
                            .padding(.top,7)
                            .padding(.bottom,4)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)

                }
                .padding(.top, 12)
                .onTapGesture {
                    withAnimation {
                        AnalyticsManager.instance.event(key: .click_filters)
                        UIApplication.shared.endEditing()
                        vm.showFilterView = true
                    }
                }
                .padding(.horizontal)
                
                
                //product view
                ScrollView(.vertical, showsIndicators: false) {
                    //show products
                    
                    VStack{
                        if filteredProducts(searchText: vm.searchText).count > 0{
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
                        } else {
                            VStack{
                                Image("productsnotfound")
                                    .resizable()
                                    .frame(width: 109, height: 109)
                                    
                                Text("No products found.")
                                    .textDefault()
                                    .padding(.top, 18)
                            }
                            .ignoresSafeArea(.keyboard, edges: .all)
                            .padding(.top, 100)
                            .opacity(vm.loading ? 0 : 1)
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
            
            tabBarManager.orderTrackerHidePage = false
            
            tabBarManager.showTracker()
            tabBarManager.show()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.showAR.toggle()
                } label: {
                    HStack{
                    Image("Catalog-AR-White-Icon")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .colorInvert()

                        Text("AR")
                            .textCustom(.coreSansC65Bold, 12, Color.col_text_main)
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 5)
                    .background(Image.bg_gradient_main.resizable().frame(width: 60, height: 24).clipShape(Capsule()))
                }
            }
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
                    AnalyticsManager.instance.event(key: .filter_close)
                }
        }
    }
}
