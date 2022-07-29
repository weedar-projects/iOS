//
//  CatalogItemListVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 17.03.2022.
//

import SwiftUI

class CatalogProductsListVM: ObservableObject {
    
    //products for list
    @Published var products: [ProductModel] = []
    
    //searching
    @Published var searchText = ""
    @Published var searchIsEditing = false
    
    @Published var showFilterView = false
    
    @Published var productInCartAnimation = false
    
    @Published var showProductDetail = false
    @Published var productDetail: ProductModel?
    
    @Published var showAR = false
    
    @Published var page = 0
   
    @Published var loading = false
    
    // filters settings
    @Published var filters: CatalogFilters = CatalogFilters()
    
    @Published var canReset = false
    
    @Published var categoryId: Int = 0{
        didSet{
            if lastCategory != categoryId{
//                self.getProducts(categoryId: categoryId, filters: filters)
            }
        }
    }
    private var lastCategory = 0
    
    //all aviable effects and brands for use
    @Published var effects: [EffectModel] = []
    @Published var brands: [BrandModel] = []
    
    init() {
        self.getEffects()
        self.getBrands()
    }
    
    //get product
    func getProducts(categoryId: Int,page: Int = 1 ,filters: CatalogFilters?){
        loading = true
                
        self.lastCategory = categoryId
        
        var params: [String : Any] = [:]
        

        if let filters = filters {
            params = composeFilters(categoryId: categoryId, catalogFilters: filters)
        }else{
            params = [CatalogFilterKey.type.rawValue : categoryId]
        }
        params["page"] = page
         
        API.shared.request(rout: .getProductsList, parameters: params) { result in
            switch result{
            case let .success(data):
                for product in data.arrayValue{
                    self.products.append(ProductModel(json: product))
                }
                self.loading = false
            case .failure(_):
                break
            }
        }
    }
    
    func nextPage(){
        self.page += 1
        getProducts(categoryId: categoryId, page: page, filters: filters)
    }
    
    //get effect for filters
  private func getEffects(){
        API.shared.request(rout: .getEffects) { result in
            switch result{
            case let .success(json):
                let loadedEffects = json.arrayValue
                for effect in loadedEffects{
                    self.effects.append(EffectModel(json: effect))
                }
            case let .failure(error):
                print("Error to load effects: \(error.message)")
            }
        }
    }
    //get brands for filters
   private func getBrands(){
        API.shared.request(rout: .getBrands) { result in
            switch result{
            case let .success(json):
                let loadedBrands = json.arrayValue
                for brand in loadedBrands{
                    self.brands.append(BrandModel(json: brand))
                }
            case let .failure(error):
                print("Error to load brands: \(error.message)")
            }
        }
    }
    
    private func composeFilters(categoryId: Int, catalogFilters: CatalogFilters) -> [String: Any] {
        var filters: [String : Any] = [:]
               
        filters = [CatalogFilterKey.type.rawValue : categoryId]
        
        if let search = catalogFilters.search{
            filters.merge(dict: [CatalogFilterKey.search.rawValue : search])
        }
        if let brand = catalogFilters.brands{
            filters.merge(dict: [CatalogFilterKey.brand.rawValue : convertToArray(value: brand)])
        }
        if let effect = catalogFilters.effects{
            filters.merge(dict: [CatalogFilterKey.effect.rawValue : convertToArray(value: effect)])
        }
        if let priceFrom = catalogFilters.priceFrom{
            filters.merge(dict: [CatalogFilterKey.priceFrom.rawValue : priceFrom])
        }
        if let priceTo = catalogFilters.priceTo{
            filters.merge(dict: [CatalogFilterKey.priceTo.rawValue : priceTo])
        }
        
        return filters
    }
    
   private func convertToArray(value: Set<Int>) -> [Int]{
        var int: [Int] = []
        for value in value {
            int.append(value)
        }
        return int
    }
    
    
}
