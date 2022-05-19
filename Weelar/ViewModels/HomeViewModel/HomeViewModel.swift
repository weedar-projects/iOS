//
//  HomeViewModel.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 03.08.2021.
//

import Foundation

class HomeViewModel: ObservableObject {
    // MARK: - Properties
    @Published var isYourOrdersShow: Bool = false
//    @Published var selectedOrderId: Int = -1
    @Published var profileIsActive: Bool = false

    
    // MARK: - Custom functions
    func sendActivity() {
        UserRepository()
            .sendActive() { result in
            switch result {
            case .success(let response):
                Logger.log(message: response.description, event: .debug)
           
            case .failure(let error):
                Logger.log(message: error.localizedDescription, event: .error)
            }
        }
    }
}
