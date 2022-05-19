//
//  ProfileMainVM.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.04.2022.
//

import SwiftUI

class ProfileMainVM: ObservableObject {
    
    @Published var myInfoItems = [ProfileMenuItemModel(icon: "Profile-Cart", title: "My orders", state: .orders),
                                  ProfileMenuItemModel(icon: "Profile-Document", title: "Document center", state: .documents)]
    
    @Published var settingsItems = [ProfileMenuItemModel(icon: "Profile-Lock", title: "Change password", state: .changePassword)]
    
    @Published var appItems = [ProfileMenuItemModel(icon: "Profile-Contact", title: "Contact us", state: .contact),
                               ProfileMenuItemModel(icon: "Profile-Info", title: "Legal", state: .legal)]
    
    @Published var selectedItem: ProfileMenuItem = .legal
    
    @Published var showView = false
    
    @Published var notificationToggle = false
    
    @Published var showNotificationAlert = false
    
    @Published var showLogOutAler = false
    
    @Published var showLoading = false
    
}

enum ProfileMenuCategory{
    case info
    case settings
    case app
}
