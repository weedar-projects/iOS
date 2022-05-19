//
//  SearchBar.swift
//  Weelar
//
//  Created by Ivan Zelenskyi on 15.09.2021.
//

import SwiftUI

struct SearchBar : View {
    @State private var showCancelButton: Bool = false
    @Binding var searchText: String
    var searchBarBackgroundColor = Color(#colorLiteral(red: 0.9882352941, green: 1, blue: 0, alpha: 1))

    var body: some View {
        HStack {
           HStack {
               Image("SearchBar-Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 15.5, height: 15.5)
                .padding(.leading, 13)

            TextField("", text: $searchText, onEditingChanged: { isEditing in
                   self.showCancelButton = true
               }, onCommit: {
                   print("onCommit")
               }).foregroundColor(.black)
            .placeholder(when: searchText.isEmpty) {
                    Text("Search")
                        .foregroundColor(.black)
                        .opacity(0.4)
            }
               Button(action: {
                   self.searchText = ""
               }) {
                   Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
               }
           }
           .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
           .foregroundColor(.secondary)
           .background(searchBarBackgroundColor)
           .cornerRadius(10.0)

           if showCancelButton  {
               Button("Cancel") {
                       UIApplication.shared.endEditing()
                       self.searchText = ""
                       self.showCancelButton = false
               }
               .foregroundColor(Color(.systemBlue))
           }
       }
       .padding(.horizontal)
       .navigationBarHidden(showCancelButton)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing()
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
