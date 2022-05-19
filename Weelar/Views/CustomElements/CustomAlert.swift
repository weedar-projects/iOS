//
//  CustomAlert.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 13.04.2022.
//

import SwiftUI


struct CustomDefaultAlert: ViewModifier {
    var title: String = ""
    var message: String = ""
        
    
    var firstBtn: Alert.Button
    var secondBtn: Alert.Button
    
    @Binding var isPresented: Bool
    
  func body(content: Content) -> some View {
    content
          .alert(isPresented: $isPresented) {
              Alert(title:
                      Text(title),
                    message:
                      Text(message),
                    primaryButton: firstBtn,
                    secondaryButton: secondBtn
              )
          }
  }
}

struct CustomErrorAlert: ViewModifier {
    var title: String = ""
    var message: String = ""
        
    @Binding var isPresented: Bool
    
  func body(content: Content) -> some View {
    content
          .alert(isPresented: $isPresented) {
              Alert(title:
                      Text(title),
                    message:
                      Text(message),
                    dismissButton: .cancel(Text("OK"))
              )
          }
  }
}

extension View {
    func customErrorAlert(title : String, message: String, isPresented: Binding<Bool>) -> some View {
      self
          .modifier(CustomErrorAlert(title: title, message: message, isPresented: isPresented))
  }
    
    func customDefaultAlert(title : String, message: String, isPresented: Binding<Bool>, firstBtn: Alert.Button,
                          secondBtn: Alert.Button) -> some View {
      self
            .modifier(CustomDefaultAlert(title: title, message: message,firstBtn: firstBtn,secondBtn: secondBtn, isPresented: isPresented))
  }
}
