//
//  WebView.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 22.09.2021.
//

import SwiftUI

struct WebView: View {
    // MARK: - Properties
    @State var urlType: URLs
    @Environment(\.presentationMode) var presentationMode
    
    
    // MARK: - View
    var body: some View {
        ZStack {
            // Bckground color
            Color.lightOnSurfaceA
                .ignoresSafeArea()

            VStack {
                // Dismiss
                HStack {
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image("xmark")
                            .frame(width: 24, height: 24, alignment: .center)
                    })
                } // HStack (Dismiss)
                .padding(.trailing, -8)
                
                // Title
                HStack {
                    Text(urlType.parameters.title.localized)
                        .lineLimit(1)
                        .lineSpacing(2.6)
                        .modifier(TextModifier(font: .coreSansC65Bold, size: 32, foregroundColor: .lightOnSurfaceB, opacity: 1))
                        .padding(.top, 20)
                    
                    Spacer()
                }
                
                // WebView
                WebViewWrapper(url: urlType.parameters.url)
            } // VStack
            .padding(.horizontal, 24)
        } // ZStack
        .padding(.top, 21)
        .opacity(1.0)
        /*
        .background(
            // TODO: HIDE AFTER CREATE DESIGN
            Image("mock-web-view")
                .resizable()
                .frame(width: 375, height: 812, alignment: .center)
                .ignoresSafeArea()
        )
         */
    } // body
}


// MARK: - PreviewProvider
#if DEBUG
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(urlType: .termsConditions)
    }
}
#endif


struct WebViewFullSize: View {
    // MARK: - Properties
    @State var urlType: URLs
    @Environment(\.presentationMode) var presentationMode
    
    
    // MARK: - View
    var body: some View {
        ZStack {
            // Bckground color
            Color.lightOnSurfaceA
                .ignoresSafeArea()
                WebViewWrapper(url: urlType.parameters.url)
     
        } // ZStack
        .edgesIgnoringSafeArea(.all)
        .opacity(1.0)
        .navigationBarHidden(true)
    } // body
}
