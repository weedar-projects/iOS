//
//  DiscountBanner.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 12.05.2022.
//

import SwiftUI
import Alamofire

struct DiscountBanner: View {
    
    @Binding var showAlert: Bool
    
    @EnvironmentObject var sessionManager: SessionManager
    var body: some View {
        ZStack{
  
            ZStack{
                Image("discountBannerStars")
                    .scaleEffect(0.9)
            VStack{
                HStack(alignment: .top){
                    Text("🤝")
                        .textDefault(size: 23)
                        .background(Color.col_white.frame(width: 32, height: 32).clipShape(Circle()))
                    VStack(alignment: .leading, spacing: 0){
                        Text("Welcome to WEEDAR \ncommunity!")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_white)
                        HStack(spacing: 0){
                            Text("Enjoy your")
                                .textCustom(.coreSansC65Bold, 16, Color.col_text_white)
                        Text("$10 off")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color.col_red_discount_bg.cornerRadius(50))
                            .padding(.leading, 4)
                        }
                        Text("towards the first order.")
                            .textCustom(.coreSansC65Bold, 16, Color.col_text_white)
                            .padding(.top,2)
                    }
                }
                .padding(.top, 58)
                
                Text("Got it")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.col_yellow_main.cornerRadius(12))
                    .padding([.horizontal, .bottom], 18)
                    .padding(.top, 48)
                    .onTapGesture {
                        self.showAlert.toggle()
                        self.disable()
                    }
            }
    
            }
            .frame(maxWidth: .infinity)
            .background(Color.col_blue_dark_discount_bg.cornerRadius(16))
            .padding(.horizontal, 53)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.col_yellow_main, style: StrokeStyle(lineWidth: 1)
                           )
                    .padding(.horizontal, 52)
            )
        }
    }
    
    func disable(){
        self.sessionManager.userData { user in
            let endpoint = "/user/\(user.id)/settings"
            API.shared.request(endPoint: endpoint, method: .put, parameters: ["showDiscountBanner": false], encoding: JSONEncoding.default) { res in
                switch res{
                case .success(_):
                    print("success bunner")
                case .failure(_):
                    print("error bunner")
                }
            }
        }
    }
}
