//
//  ProfileList.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct ProfileList: View{
    @Binding var selectedItem: ProfileMenuItem
    @Binding var showView: Bool
    
    @State var title = ""
    @Binding var menuItems: [ProfileMenuItemModel]
    
    
    var body: some View{
        Text(title)
            .textCustom(.coreSansC65Bold, 14, Color.col_text_second)
            .padding(.leading, 36)
            .hLeading()
            .padding(.top,24)
        
        ForEach(menuItems, id: \.self) { item in
            ProfileListButton(icon: item.icon, title: item.title, state: item.state, additionaLinfo: item.additionaLinfo) {
                selectedItem = item.state
                showView = true
            }
        }
    }
}
