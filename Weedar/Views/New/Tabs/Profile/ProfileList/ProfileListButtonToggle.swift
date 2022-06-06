//
//  ProfileListButtonToggle.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 20.04.2022.
//

import SwiftUI

struct ProfileListButtonToggle: View {
    @State var icon = ""
    @State var title = ""
    @Binding var isOn: Bool
    
    var action: () -> Void
    
    var body: some View{
        HStack{
            Toggle(isOn: $isOn){
                Image(icon)
                
                Text(title)
                    .textCustom(.coreSansC65Bold, 16, Color.col_text_main)
                Spacer()
            }
            .toggleStyle(
                SwitchToggleStyle(tint: ColorManager.Profile.lilacColor)
            )
            
            .onChange(of: isOn) { value in
                action()
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 48)
        .background( Color.col_bg_second
                        .cornerRadius(12))
        .padding(.horizontal, 16)
    }
}

enum ProfileMenuItem {
    case orders
    case documents
    case email
    case phone
    
    case notification
    case changePassword
    
    case contact
    case legal
}
