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
    
    //get product
    func getProductsForAR(success: @escaping ()->Void){
        API.shared.request(rout: .getProductsList) { result in
            switch result{
            case let .success(data):
                var products: [ProductModel] = []
                for product in data.arrayValue{
                    products.append(ProductModel(json: product))
                }
                ProductsViewModel.shared.products = products
                success()
            case .failure(_):
                break
            }
        }
    }
}
