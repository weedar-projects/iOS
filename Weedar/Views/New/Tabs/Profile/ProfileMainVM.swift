//
//  ProfileMainVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.04.2022.
//

import SwiftUI

class ProfileMainVM: ObservableObject {
    
    @Published var myInfoItems = [ProfileMenuItemModel(icon: "Profile-Cart", title: "My orders", state: .orders),
                                  ProfileMenuItemModel(icon: "Profile-Document", title: "Document center", state: .documents),
                                  ProfileMenuItemModel(icon: "Profile-Email", title: "Email", state: .email, additionaLinfo: ""),
                                  ProfileMenuItemModel(icon: "Profile-Phone", title: "Phone", state: .phone, additionaLinfo: "")
    ]
    
    @Published var settingsItems = [ProfileMenuItemModel(icon: "Profile-Lock", title: "Change password", state: .changePassword)]
    
    @Published var appItems = [ProfileMenuItemModel(icon: "Profile-Contact", title: "Contact us", state: .contact),
                               ProfileMenuItemModel(icon: "Profile-Info", title: "Legal", state: .legal)]
    
    @Published var selectedItem: ProfileMenuItem = .legal
    
    @Published var showView = false
    
    @Published var notificationToggle = false
    
    @Published var showNotificationAlert = false
    
    @Published var showLogOutAler = false
    
    @Published var showLoading = false
   
    
    func setData(email: String, phone: String) {
        print("Update items set")
        self.myInfoItems = [ProfileMenuItemModel(icon: "Profile-Cart", title: "My orders", state: .orders),
                                          ProfileMenuItemModel(icon: "Profile-Document", title: "Document center", state: .documents),
                                          ProfileMenuItemModel(icon: "Profile-Email", title: "Email", state: .email, additionaLinfo: email),
                            ProfileMenuItemModel(icon: "Profile-Phone", title: "Phone", state: .phone, additionaLinfo: phone)
        ]
    }
}



enum ProfileMenuCategory{
    case info
    case settings
    case app
}
