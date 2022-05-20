//
//  ProfileMainVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.04.2022.
//

import SwiftUI

class ProfileMainVM: ObservableObject {
    
    @Published var myInfoItems:[ProfileMenuItemModel] = []
    
    @Published var settingsItems = [ProfileMenuItemModel(icon: "Profile-Lock", title: "Change password", state: .changePassword)]
    
    @Published var appItems = [ProfileMenuItemModel(icon: "Profile-Contact", title: "Contact us", state: .contact),
                               ProfileMenuItemModel(icon: "Profile-Info", title: "Legal", state: .legal)]
    
    @Published var selectedItem: ProfileMenuItem = .legal
    
    @Published var showView = false
    
    @Published var notificationToggle = false
    
    @Published var showNotificationAlert = false
    
    @Published var showLogOutAler = false
    
    @Published var showLoading = false
    
    @Published var user: UserModel?
    
    init(){
        getUserData(userData: {data in
            self.myInfoItems = [ProfileMenuItemModel(icon: "Profile-Cart", title: "My orders", state: .orders),
                                ProfileMenuItemModel(icon: "Profile-Document", title: "Document center", state: .documents),
                                ProfileMenuItemModel(icon: "Profile-Email", title: "Email", subtitle: data.email, state: .email),
                                ProfileMenuItemModel(icon: "Profile-Phone", title: "Phone", subtitle: data.phone, state: .phone)]
            
        })
    }
    
    func getUserData(userData:@escaping(UserModel)-> Void){
            API.shared.request(rout: .getCurrentUserInfo) { result in
                switch result{
                case let .success(json):
                    let user = UserModel(json: json)
                    userData(user)
                case let .failure(error):
                    print("error to load user data: \(error)")
                }
            }
        }
}

enum ProfileMenuCategory{
    case info
    case settings
    case app
}
