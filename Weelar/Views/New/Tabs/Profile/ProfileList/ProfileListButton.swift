//
//  ProfileListButton.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct ProfileListButton: View {
    
    @State var icon = ""
    @State var title = ""
    
    var state: ProfileMenuItem
    
    @State var additionaLinfo: String?
    
    @EnvironmentObject var tabBarManager: TabBarManager
    
    var action: () -> Void
    
    var body: some View{
        ZStack{
            ZStack{
                Color.col_bg_second
                    .cornerRadius(12)
                HStack{
                    Image(icon)
                    
                    Text(title)
                        .textCustom(.coreSansC65Bold, 16, Color.col_black)
                    
                    Spacer()
                    
                    if let info = additionaLinfo{
                        Text(info)
                            .textSecond()
                    }else{
                        Image("arrowRight")
                    }
                }
                .padding(.horizontal, 18)
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .onTapGesture {
                action()
                tabBarManager.hide()
            }
        }
    }
}
