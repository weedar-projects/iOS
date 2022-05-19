//
//  ProductsViewModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI
import Combine

class ProductsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var products: [Product] = [] // TODO:  move to database
    public var filteredProducts: [Product] = []
    public static let shared = ProductsViewModel()

    @Published var filtersRequestModel = FiltersRequestModel()

//    @Published var brands: [HorizontalItemModel] = []
//    @Published var effects: [HorizontalItemModel] = []

    @Published var isBrandsFetched: Bool = false
    @Published var isEffectsFetched: Bool = false

    @Published var isActivityLoadShow = true
    @Published var isActivityLoadSuccess = false
    private var cancelables = [AnyCancellable]()
    
    // MARK: - Initialization
    private init() {}
        
    func onAppear() {
        
        Publishers.CombineLatest($products, $filtersRequestModel)
            .map { products, filters in
                products.filter { filters.includedForFilters($0) }
            }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] value in
                self?.filteredProducts = value
            })
            .store(in: &cancelables)
    }

    func onDisappear() {
        cancelables = []
    }
    
    
    func removeAllFilters(){
        filtersRequestModel.priceTo = nil
        filtersRequestModel.priceFrom = nil
        filtersRequestModel.brands?.removeAll()
        filtersRequestModel.effects?.removeAll()
    }
    
    // MARK: - Custom functions
    func filterProductsBy(categoryID: Int) -> [Product] {
        return filteredProducts.filter { $0.type.id == categoryID }
    }
        
    func getProduct(id: Int) -> Product? {
        let product = ProductsViewModel.shared.products.first { $0.id == id }
        return product
    }
    
    func itemsPerCategory(id: Int) -> Int {
        return ProductsViewModel.shared.products.map({ $0.type.id == id ? 1 : 0 }).reduce(0, +)
    }
    
    // write model to documents directory
    func getModel(id: String, completion: @escaping () -> Void) {
        guard let dir = try? FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
        let fileURL = dir.appendingPathComponent("\(id)")
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            ModelRepository().getModel(id: id) { result in
                switch result {
                case .success(let data):
                    if (FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)) {
                        do {
                            let dataCopy = data
                            try dataCopy.write(to: fileURL)
                        } catch (let error) {
                            print(error)
                        }
                    } else {
                        print("File not created.")
                    }
                case .failure(let error):
                    print(error)
                }
                completion()
            }
        } else {
            completion()
        }
    }
    
    /// API `Get Products`
    func fetchProducts(finished: @escaping() -> Void) {
        ProductRepository
            .shared
            .getProducts(withParameters: FiltersRequestModel()) { result in
                switch result {
                case .success(let products):
                    DispatchQueue.main.async {
                        Logger.log(message: "Products: \n\(products)", event: .debug)
                        
                        self.products.removeAll()
                        self.products.append(contentsOf: products)
//                        ARModelsManager.shared.getAllModels()
                        finished()
                    }
                    
                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                    finished()
                }
            }
    }
    
    /// API `Get Brands`
    func fetchBrands() {
        BrandRepository
            .shared
            .getBrands { result in
                switch result {
                case .success(let brands):
                    DispatchQueue.main.async {
                        Logger.log(message: "Brands: \n\(brands)", event: .debug)

//                        self.brands.append(contentsOf: brands.map({ HorizontalItemModel(fromBrand: $0) }))
                        self.isBrandsFetched = true
                    }
                    
                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                }
            }
    }

    /// API `Get Effects`
    func fetchEffects() {
        EffectRepository
            .shared
            .getEffects { result in
                switch result {
                case .success(let effects):
                    DispatchQueue.main.async {
                        Logger.log(message: "Effects: \n\(effects)", event: .debug)
                        
//                        self.effects.append(contentsOf: effects.map({ HorizontalItemModel(fromEffect: $0) }))
                        self.isEffectsFetched = true
                    }
                    
                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                }
            }
    }

}

extension FiltersRequestModel {
    func includedForFilters(_ product: Product) -> Bool {
        return inPriceRange(price: product.price) && inBrands(brandId: product.brand.id) && inEffects(effectsOfProducts: Set(product.effects.map(\.id)))
    }
    
    private func inPriceRange(price: Double) -> Bool {
        guard let priceFrom = priceFrom, let priceTo = priceTo else { return true }
        return price >= Double(priceFrom) && price <= Double(priceTo)
    }
    
    private func inBrands(brandId: Int) -> Bool {
        guard let brands = brands, !brands.isEmpty else { return true }
        return brands.contains(brandId)
    }
    
    private func inEffects(effectsOfProducts: Set<Int>) -> Bool {
        guard let effects = effects, !effects.isEmpty else { return true }
        return effects.isSubset(of: effectsOfProducts)
    }
}
