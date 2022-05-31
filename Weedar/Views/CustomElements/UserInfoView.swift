//
//  UserInfoView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    @State var user: UserModel?
    
    var body: some View{
        VStack(alignment: .leading){
            Text("\(user?.name ?? ""), \n\(user?.addresses.first?.addressLine1 ?? ""), \n\(user?.phone ?? "")")
                .textDefault()
                .lineSpacing(4.8)
                .padding()
                .hLeading()
        }
        .frame(maxWidth: .infinity)
        .background(
            RadialGradient(colors: [Color.col_gradient_blue_second,
                                    Color.col_gradient_blue_first],
                           center: .center,
                           startRadius: 0,
                           endRadius: 220)
            .clipShape(CustomCorner(corners: .allCorners, radius: 12))
            .opacity(0.25)
        )
        .padding(.top,8)
        .padding(.horizontal, 24)
        
        .onAppear {
            sessionManager.getUserData {
                self.user = sessionManager.user
            }
        }
    }
}
