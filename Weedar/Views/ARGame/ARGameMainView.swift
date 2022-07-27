//
//  ARGameMainView.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 27.07.2022.
//

import SwiftUI

struct ARGameMainView: View {
    @Environment(\.presentationMode) var mode
    @State var manager = ARGameManger.shared
    var body: some View {
        ZStack{
            ARGameRepresentableView()
                .edgesIgnoringSafeArea(.all)
            
            if !manager.objectFounded{
            Text("Find object")
                .textCustom(.coreSansC65Bold, 18, .col_text_white)
                .padding()
                .background(Color.col_black.opacity(0.4).cornerRadius(12))
                .vBottom()
                .padding(.bottom, 50)
            }
            
            //Back button
            Button {
                mode.wrappedValue.dismiss()
            } label: {
                
                Image("Back-Navigation-Button")
                    .resizable()
                    .frame(width: 45, height: 45)
                
            }
            .hLeading()
            .vTop()
            .padding()
        }
        .navigationBarHidden(true)
    }
}

struct ARGameMainView_Previews: PreviewProvider {
    static var previews: some View {
        ARGameMainView()
    }
}
