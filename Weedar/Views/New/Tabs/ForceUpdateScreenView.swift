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
            Image("bgForceUpdate_image")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            
            VStack{
                //Logo
                Image("logo_light")
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
            
            
            ZStack{
                Text( "Go to Appstore")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Image.bg_gradient_main)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, getSafeArea().bottom + 10)
            .vBottom()
            .onTapGesture {
                if let url = URL(string: "itms-apps://apple.com/app/id1601307559") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct ForceUpdateScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ForceUpdateScreenView()
    }
}
