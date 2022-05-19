//
//  CustomNavigationBackBtn.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 08.04.2022.
//

import SwiftUI

struct CustomNavigationBackBtn: ViewModifier {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    var title: String?
    var hideBtn: Bool
    
    
  func body(content: Content) -> some View {
    content
          .navigationTitle(title ?? "")
          .navigationBarBackButtonHidden(true)
          .toolbar(content: {
              ToolbarItem(placement: .navigationBarLeading) {
                  ZStack{
                      Image("backNavBtn")
                          .resizable()
                          .frame(width: 14, height: 14)
                  }
                  .opacity(hideBtn ? 0 : 1)
                  .onTapGesture {
                      self.mode.wrappedValue.dismiss()
                  }
                  
              }
          })     
  }
}

extension View {
    func navBarSettings(_ navTitle : String = "", backBtnIsHidden : Bool = false) -> some View {
      self
            .modifier(CustomNavigationBackBtn(title: navTitle, hideBtn: backBtnIsHidden))
  }
}
