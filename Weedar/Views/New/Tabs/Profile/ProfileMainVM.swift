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
    
    @Published var notificationToggle = true
    
    @Published var showNotificationAlert = false
    
    @Published var showLogOutAlert = false
    
    @Published var showLoading = false
   
    @Published var showDeleteAccountAlert = false
    
    func setData(email: String, phone: String) {
        print("Update items set")
        self.myInfoItems = [ProfileMenuItemModel(icon: "Profile-Cart", title: "My orders", state: .orders),
                                          ProfileMenuItemModel(icon: "Profile-Document", title: "Document center", state: .documents),
                                          ProfileMenuItemModel(icon: "Profile-Email", title: "Email", state: .email, additionaLinfo: email),
                            ProfileMenuItemModel(icon: "Profile-Phone", title: "Phone", state: .phone, additionaLinfo: format(with: "+X (XXX) XXX-XXXXXX", phone: phone))
        ]
    }
    
    
    private func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
}



enum ProfileMenuCategory{
    case info
    case settings
    case app
}
