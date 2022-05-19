//
//  ForceUpdateScreenView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 14.04.2022.
//

import SwiftUI

struct ForceUpdateScreenView: View {
    var body: some View {
        ZStack{
            Color.col_black
                .edgesIgnoringSafeArea(.all)
            Image("splash-background-lines")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3, alignment: .top)
                .opacity(0.5)
                .edgesIgnoringSafeArea(.top)
                .vTop()
            
            VStack{
                //Logo
                Image("logo_new")
                    .resizable()
                    .frame(width: 150, height: 162)
                
                Text("Update Available")
                    .textCustom(.coreSansC65Bold, 40, Color.col_white)
                    .padding(.top,43)
                
                Text("To use the application, you need to update it to the latest version available.")
                    .textCustom(.coreSansC65Bold, 16, Color.col_white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 15)
                    .padding(.horizontal)
            }
            .offset(y: -(getRect().height / 7))
            
            MainButton(title: "Go to Appstore") {
                if let url = URL(string: "itms-apps://apple.com/app/id1601307559") {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal)
            .vBottom()
            
        }
    }
}

struct ForceUpdateScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ForceUpdateScreenView()
    }
}
