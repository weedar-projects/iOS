//
//  ProfileMenuItemModel.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct ProfileMenuItemModel: Hashable {
    var id = UUID().uuidString
    var type: ProfileMenuItemType = .button
    var icon: String
    var title: String
    var state: ProfileMenuItem
    
    var additionaLinfo: String?
    
    enum ProfileMenuItemType {
        case button
        case toggle
    }
}
