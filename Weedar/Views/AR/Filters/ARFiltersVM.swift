//
//  ARFiltersVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 15.06.2022.
//

import SwiftUI

class ARFiltersVM: ObservableObject {

    @Published var showFilterView = false
    @Published var filters: CatalogFilters = CatalogFilters()
    @Published var effects: [EffectModel] = []
    @Published var brands: [BrandModel] = []
    @Published var canReset = false
    
    init() {
        self.getEffects()
        self.getBrands()
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
}
