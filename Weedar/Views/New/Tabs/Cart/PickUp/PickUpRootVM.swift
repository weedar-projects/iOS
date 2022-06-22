//
//  PickUpRootVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.06.2022.
//

import SwiftUI

class PickUpRootVM: ObservableObject{
    
    @Published var selectedTab: PickUpShopListState = .list
    @Published var selectedStore: StoreModel?
    @Published var selectedRadius = 10
    @Published var showStoreInfo = false
    
    @Published var avaibleStores: [StoreModel] = []
    @Published var error = ""
    
    @Published var showRaduisPicker = false
    
    init(){
        getStores()
    }
    
    func getStores(){
        API.shared.request(rout: .getAllStores, method: .get) { result in
            switch result{
            case let .success(json):
                let stores = json.arrayValue
                for store in stores{
                    self.avaibleStores.append(StoreModel(json: store))
                }

            case let .failure(error):
                self.error = error.message
            }
        }
    }
}
