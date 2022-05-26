//
//  SwiftUIView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 26.05.2022.
//

import SwiftUI
import Amplitude

struct OnboardingView: View {
    @State var page = 1
    
    @State var showAlertWebFirst = false
    @State var showAlertWebSecond = false
    
    @Environment(\.openURL) var openURL
    
    var lastPageAction: () -> Void = {}
    
    var body: some View {
        ZStack{
            Color.col_black
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                
                Image.logoLight
                    .resizable()
                    .frame(width: 169, height: 184)
                
                switch page{
                case 1:
                    pageView(mainText: "Are you over 21 years old?",
                             secondText: "You are also allowed to use our service \nif you are 18 years old and you have \nphysician's recommendation",
                             thirdText: "Smoking may be hazardous to your health. \nWe do not promote smoking and the use \nof smoking products that can  expose the \nuser to physical or mental harm.")
                    .customDefaultAlert(title: "Dear customer,",
                                        message: "Cannabis is legal in California.\nYou can buy cannabis if you are: \n18 or older with a ph ysician’s \nrecommendation (medicinal use) \n and 21 or older (adult use).",
                                        isPresented: $showAlertWebFirst,
                                        firstBtn: Alert.Button.default(Text("Cancel"), action: {
                        self.showAlertWebFirst = false
                    }),
                                        secondBtn: Alert.Button.destructive(Text("Go to site"),
                                                                       action: {
                        if let url = URL(string: "https://cannabis.ca.gov/consumers/whats-legal") {
                            openURL(url)
                            if UserDefaults.standard.bool(forKey: "EnableTracking"){
                                Amplitude.instance().logEvent("site_age_alert")
                            }
                        }
                    }))
                    
                case 2:
                    pageView(mainText: "California residents only",
                             secondText: "Delivery is only available in California. \nDo you live in mentioned area?")
                    .customDefaultAlert(title: "Dear customer,",
                                        message: "Thank you for downloading WEEDAR\n app! We are currently supporting \nbusiness in California state only. The \nteam is planning to expand our business \nto other states in a near future. Please \ndo not hesitate to visit our site \nhttps://www.weedar.io/ for the latest updates as our business is growing.",
                                        isPresented: $showAlertWebSecond,
                                        firstBtn: Alert.Button.default(Text("Cancel"), action: {
                        self.showAlertWebSecond = false
                    }),
                                        secondBtn: Alert.Button.destructive(Text("Go to site"),
                                                                       action: {
                        if let url = URL(string: "https://www.weedar.io/") {
                            openURL(url)
                        }
                    }))
                    

                default:
                    EmptyView()
                }
            }
            .vTop()
            .padding(.top, 120)
        }
        }
    
    @ViewBuilder
    func pageView(mainText: String, secondText: String, thirdText: String = "") -> some View {
        Group{
            Text(mainText)
                .textCustom(.coreSansC65Bold, 40, Color.col_text_white)
            
            Text(secondText)
                .textCustom(.coreSansC45Regular, 16, Color.col_text_white.opacity(0.6))
                .padding(.top)
            
            Text(thirdText)
                .textCustom(.coreSansC45Regular, 16, Color.col_text_white)
                .padding(.top)
            
        }
        .multilineTextAlignment(.center)
       
        Spacer()
        
        HStack(spacing: 12){
            Button {
                switch page{
                case 1:
                    self.showAlertWebFirst.toggle()
                case 2:
                    self.showAlertWebSecond.toggle()
                default:
                    break
                }
            } label: {
                Text("I’m not")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_white)
                    .padding(.horizontal, 50)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(ButtonBGDarkGradient())
            
            
            Button {
                switch page{
                case 1:
                    self.page = 2
                case 2:
                    lastPageAction()
                default:
                    break
                }
                
            } label: {
                Text("I am")
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                    .padding(.horizontal, 50)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(
                Image.bg_gradient_main
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
        }
        .padding(.horizontal, 24)
        
    }
    
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}


struct ButtonBGDarkGradient: View{
    var body: some View{
        ZStack{
            Color.col_gradient_black_second
            Capsule()
                .fill(Color.col_gradient_black_first)
                .blur(radius: 20)
                .scaleEffect(1.1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.col_border_black, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
