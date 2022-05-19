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
        .background(Color.col_bg_second.cornerRadius(12))
        .padding(.top,8)
        .padding(.horizontal, 24)
        
        .onAppear {
            sessionManager.getUserData {
                self.user = sessionManager.user
            }
        }
    }
}
