//
//  TabBarPage.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 05.10.2021.
//

import SwiftUI

struct TabBarPage: Identifiable {
    var id = UUID()
    var page: Any
    var icon: String
    var title: String
    var tag: SelectedTab
}
