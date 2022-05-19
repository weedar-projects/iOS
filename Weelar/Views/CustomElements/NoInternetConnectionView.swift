//
//  NoInternetConnection.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 09.05.2022.
//

import SwiftUI

struct NoInternetConnectionView: View {
    var body: some View {
        ZStack{
            Color.col_white.edgesIgnoringSafeArea(.all)
            
            Image("Background_Logo")
                .hTrailing()
                .offset(y: 65)
            
            VStack{
                Image("internetConnection")
                    .resizable()
                    .frame(width: 39, height: 37)
                    .scaledToFill()
                    .padding(.top, 36)
                
                Text("Please check your \ninternet conection.")
                    .textCustom(.coreSansC45Regular, 18, Color.col_text_main)
                    .padding(.bottom, 19)
                    .padding(.top, 17)
                
            }
            .frame(maxWidth: getRect().width)
            .background(Color.col_blue_alert_bg.cornerRadius(16))
            .padding(.horizontal, 53)
        }
    }
}

