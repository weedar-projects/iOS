//
//  CustomSearch.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 04.04.2022.
//

import SwiftUI
 
struct CustomSearch: View {
    
    @Binding var searchText: String
    @Binding var isEditing: Bool
    @State var showCancel = false
    
    var body: some View {
        HStack{
            HStack{
                Image("SearchBar-Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15.5, height: 15.5)
                
                
                TextField("Search", text: $searchText, onEditingChanged: { focused in
                    AnalyticsManager.instance.event(key: .click_search)
                    withAnimation {
                        self.showCancel = focused
                        self.isEditing = focused
                    }
                })
                
                Spacer(minLength: 0)
                
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.col_text_second)
                }
                .opacity(isEditing && searchText != "" ? 1 : 0)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(
                ZStack{
                    Color.col_gray_main
                    
                    Capsule()
                        .fill(Color.col_white)
                        .blur(radius: 35)
                        .scaleEffect(0.6)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
            )
//            .background(Color.col_yellow_main.cornerRadius(10).frame(height: 40))
            .padding(isEditing ? .leading : .horizontal)

            if showCancel{
                Button {
                    UIApplication.shared.endEditing()
                    AnalyticsManager.instance.event(key: .search_cancel)
                    withAnimation {
                        showCancel = false
                    }
                } label: {
                    Text("Cancel")
                        .textCustom(.coreSansC45Regular, 16, Color.col_text_second)
                }
                .padding(.trailing, 12)
            }
        }
        .frame(height: 40)
 
    }
}
