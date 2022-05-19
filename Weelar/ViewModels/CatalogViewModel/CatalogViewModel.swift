//
//  CatalogViewModel.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 14.09.2021.
//

import SwiftUI



struct CatalogItem: Hashable {
    var id: Int
    var name: String
    var thc: Int
    var price: Double
    var brand: Double
    var weight: Double
    var strain: String
}

class CatalogViewModel: ObservableObject {
    // MARK: - Properties
    @Published var categories: [CatalogCategoryModel] = []
    
    @Published var didLoad: Bool = false

    
    // MARK: - Custom functions
    func loadCategories(completion: @escaping (Bool) -> Void) {
        TypeRepository().getTypes() { result in
            switch result {
            case .success(let types):
                DispatchQueue.main.async {
                    var newCategories: [CatalogCategoryModel] = []
                    for type in types {
//                        newCategories.append(CatalogCategoryModel(id: type.id,
//                                                             name: type.name.capitalized,
//                                                             itemsCount: ProductsViewModel.shared.itemsPerCategory(id: type.id)
//                        ))
                    }
                    self.categories = newCategories
                    completion(true)
                    self.didLoad = true
                }
            case .failure(let error):
                print(error)
                completion(false)
                self.didLoad = true
            }
        }
    }
}
