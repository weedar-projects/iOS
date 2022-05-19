//
//  CatalogVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 17.03.2022.
//

import SwiftUI
import SwiftyJSON


class CatalogVM: ObservableObject {

    @Published var categories: [CatalogCategoryModel] = []
    
    @Published var showLoader: Bool = true
    
    @StateObject var productsViewModel = ProductsViewModel.shared
    
    @Published  var showWebView = false
    
    @Published var showDiscountAlert = false
    
    @Published var id = UUID().uuidString

    let manager = ARModelsManager.shared
    
    //get categories
    func loadCategories(completion: @escaping (Bool) -> Void) {
        self.categories.removeAll()
        API.shared.request(rout: .getCatalogCategory) { result in
            switch result{
            case let .success(json):
                let categories = json.arrayValue
                
                for category in categories {
                    self.categories.append(CatalogCategoryModel(json: category))
                }
                completion(true)
                
            case .failure(_):
                completion(false)
                break
            }
        }
    }
    
    //FOR LOADING AR FIX
    /// API `Get Products`
    func fetchProducts(finished: @escaping() -> Void) {
        ProductRepository
            .shared
            .getProducts(withParameters: FiltersRequestModel()) { result in
                switch result {
                case .success(let productsData):
                    DispatchQueue.main.async {
                        
                        var loadedProducts: [Product] = []
                        loadedProducts.append(contentsOf: productsData)
                        ProductsViewModel.shared.products = loadedProducts
                        finished()
                    }
                    
                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                    finished()
                }
            }
    }
}
