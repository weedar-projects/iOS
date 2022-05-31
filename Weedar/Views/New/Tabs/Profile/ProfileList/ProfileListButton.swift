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
                RadialGradient(colors: [Color.col_gradient_blue_second,
                                        Color.col_gradient_blue_first],
                               center: .center,
                               startRadius: 0,
                               endRadius: 220)
                .clipShape(CustomCorner(corners: .allCorners, radius: 12))
                .opacity(0.25)
                
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
