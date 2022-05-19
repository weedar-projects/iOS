//
//  SupportViewModel.swift
//  Weelar
//
//  Created by vtsyomenko on 25.08.2021.
//

import Foundation

class SupportViewModel: ObservableObject {
    func sendSupportMessage(_ title:String, message: String) {
        SupportRepository.shared.sendSupportMessage(SupportMessage(title: title, message: message)) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}
