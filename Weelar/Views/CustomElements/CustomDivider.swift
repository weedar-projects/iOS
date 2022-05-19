//
//  CustomDivider.swift
//  Weedar
//
//  Created by Vladyslav Condratiev on 11.03.2022.
//

import SwiftUI

struct CustomDivider: View {
    var body: some View{
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .foregroundColor(Color.col_borders)
    }
}

struct CustomDivider_Previews: PreviewProvider {
    static var previews: some View {
        CustomDivider()
    }
}
