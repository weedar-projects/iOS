//
//  ProfileViewModel.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 16.09.2021.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    // MARK: - Properties
    enum ActiveSheet: Identifiable {
        case orders, documents, delivery, password, contactus, legal
        
        var id: Int {
            hashValue
        }
    }

    let url: URLs = .termsConditions

    @Published var profileIsActive : Bool = false
    @Published var isYourOrdersShow: Bool = false
//    @Published var selectedOrderId: Int = -1
    @Published var isWebViewShow: Bool = false
    @Published var isSendMessage : Bool = false
    
    @Published var userInfo: UserResponse?
    
    @Published var activeSheet: ActiveSheet?
    
    // MARK: - Custom functions
    func getUserInfo(finished: @escaping ()-> Void) {
        let userId = UserDefaultsService().get(fromKey: .user) as! Int
        
        UserRepository
            .shared
            .getUserInfo(userId: userId) { [weak self] result in
                switch result {
                case .success(let userInfo):
                    self?.userInfo = userInfo
                    finished()
                    
                case .failure(let error):
                    Logger.log(message: error.localizedDescription, event: .error)
                }
            }
    }
}
